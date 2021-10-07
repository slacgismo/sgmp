from decimal import Decimal
import enum
from flask import Blueprint, json, jsonify, request
import boto3
from boto3.dynamodb.conditions import Key
import numpy as np

from models.analytics import Analytics
from models.device import Device

from utils.functions import err_json, get_obj_path
from utils.analytics_engine import AnalyticsEngine
from utils.tsdb import get_tsdb_conn
import utils.config as config

api_data = Blueprint('data', __name__)

agg_functions = {
    'min': np.min,
    'max': np.max,
    'avg': np.mean
}
arg_functions = {
    'min': np.argmin,
    'max': np.argmax
}

@api_data.route('/read', methods=['POST'])
def data_read():
    data = request.json

    # Verify data
    if 'start_time' not in data:
        return err_json('bad request')
    if 'end_time' not in data:
        return err_json('bad request')
    if 'type' not in data:
        return err_json('bad request')

    if data['type'] != 'device' and data['type'] != 'analytics':
        return err_json('bad request')

    # Process device data read
    if data['type'] == 'device':
        if 'device_id' not in data:
            return err_json('bad request')

        start_time = int(data['start_time'])
        end_time = int(data['end_time'])
        device_id = int(data['device_id'])

        dynamodb = boto3.resource('dynamodb', region_name='us-west-1')
        table = dynamodb.Table(config.DYNAMODB_TALBE)
        response = table.query(
            ScanIndexForward=False,
            KeyConditionExpression=
                Key('device_id').eq(device_id) &
                Key('timestamp').between(start_time, end_time)
        )

        lst = []
        for item in response['Items']:
            lst.append({
                'timestamp': item['timestamp'],
                'data': item['device_data']
            })

        return jsonify({
            'status': 'ok',
            'data': lst
        })

    # Process analytics data read
    if data['type'] == 'analytics':
        if 'analytics_id' not in data and 'formula' not in data:
            return err_json('bad request')
        if 'agg_function' in data:
            if data['agg_function'] not in agg_functions:
                return err_json('agg_function is invalid')
        if 'agg_function' in data and 'average' in 'data':
            return err_json('bad request')

        # Read request data
        start_time = int(data['start_time'])
        end_time = int(data['end_time'])

        formula = ''

        if 'analytics_id' in data:
            analytics_id = int(data['analytics_id'])

            # Retrieve Analytics object
            analytics = Analytics.query.filter_by(analytics_id=analytics_id).first()
            if analytics is None:
                return err_json('analytics not found')
            
            formula = analytics.formula
        else:
            formula = data['formula']

        # Parse the formula expression
        engine = AnalyticsEngine()
        try:
            stack = engine.parse_expression(formula)
        except Exception as e:
            return err_json(str(e))
        
        # Verify all devices are present
        idents = engine.collect_identifiers()

        if len(stack) == 1 and len(idents) == 1:
            # Use new PostgreSQL store
            return process_analytics_postgresql(data, idents[0])
        else:
            # Use DynamoDB
            return process_analytics_dynaomdb(data, engine, stack, idents)
        

    return jsonify({
        'status': 'ok'
    })

def process_analytics_postgresql(data, ident):
    start_time = float(data['start_time']) / 1000
    end_time = float(data['end_time']) / 1000
    components = ident.split('.')
    device_name = components[0]

    # Verify device exists
    device = Device.query.filter_by(name=device_name).first()
    if device is None:
        return err_json('device %s does not exist (evaluating %s)'
            % (device_name, ident))

    device_id = device.device_id

    # Field name
    field = '.'.join(components[1:])

    # Special case #1: aggregate function
    if 'agg_function' in data:
        agg = data['agg_function']

        # Execute query
        conn = get_tsdb_conn()
        cursor = conn.cursor()

        if agg == 'min':
            sql = 'SELECT DISTINCT ON (device_id) timestamp, value_decimal FROM data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND device_id = %s AND field = %s ORDER BY device_id, value_decimal ASC'
            cursor.execute(sql, (start_time, end_time, device_id, field))
            row = cursor.fetchone()
            cursor.close()
            return jsonify({
                'status': 'ok',
                'timestamp': int(row[0].timestamp() * 1000),
                'value': row[1]
            })
        elif agg == 'max':
            sql = 'SELECT DISTINCT ON (device_id) timestamp, value_decimal FROM data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND device_id = %s AND field = %s ORDER BY device_id, value_decimal DESC'
            cursor.execute(sql, (start_time, end_time, device_id, field))
            row = cursor.fetchone()
            cursor.close()
            return jsonify({
                'status': 'ok',
                'timestamp': int(row[0].timestamp() * 1000),
                'value': row[1]
            })
        elif agg == 'avg':
            sql = 'SELECT AVG(value_decimal) FROM data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND device_id = %s AND field = %s'
            cursor.execute(sql, (start_time, end_time, device_id, field))
            row = cursor.fetchone()
            cursor.close()
            return jsonify({
                'status': 'ok',
                'value': row[0]
            })

    # Execute query
    conn = get_tsdb_conn()
    cursor = conn.cursor()

    if 'average' in data:
        # Special case #2: average bucket
        timespan = str(data['average']) + ' milliseconds'
        sql = 'SELECT time_bucket(%s, timestamp) AS time, AVG(value_decimal) AS average FROM data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND device_id = %s AND field = %s GROUP BY time ORDER BY time'
        cursor.execute(sql, (timespan, start_time, end_time, device_id, field))
    else:
        # Construct query
        sql = 'SELECT timestamp, value_decimal FROM data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND device_id = %s AND field = %s'
        cursor.execute(sql, (start_time, end_time, device_id, field))

    # Retrieve results
    rows = cursor.fetchall()
    cursor.close()

    result = []
    for row in rows:
        timestamp = int(row[0].timestamp() * 1000)
        value = row[1]
        result.append({
            'timestamp': timestamp,
            'value': value
        })

    return jsonify({
        'status': 'ok',
        'data': result
    })

def process_analytics_dynaomdb(data, engine, stack, idents):
    evaluate_message = 'Identifiers: '
    device_reqs = dict()
    start_time = float(data['start_time']) / 1000
    end_time = float(data['end_time']) / 1000

    for ident in idents:
        evaluate_message += ident
        evaluate_message += ', '
        components = ident.split('.')
        device_name = components[0]
        path = '.'.join(components[1:])
        if device_name in device_reqs:
            device_reqs[device_name]['path'].add(path)
            continue
        
        device = Device.query.filter_by(name=device_name).first()
        if device is None:
            return err_json('device %s does not exist (evaluating %s)'
                % (device_name, ident))
        
        device_reqs[device_name] = {
            'id': device.device_id,
            'path': set([path])
        }
    
    evaluate_message += '\n'

    readings = dict()
    for name, req in device_reqs.items():
        device_reqs[name]['path'] = list(req['path'])
        for path in req['path']:
            readings['%s.%s' % (name, path)] = dict()
        
    # Grab all data
    ts_list = set()
    """
    dynamodb = boto3.resource('dynamodb', region_name='us-west-1')
    table = dynamodb.Table(config.DYNAMODB_TALBE)
    for device_name, req in device_reqs.items():
        device_id = req['id']
        first = True
        last_evaluated_key = None
        # Take care of pagination for large result set
        while first or last_evaluated_key is not None:
            first = False
            if last_evaluated_key is not None:
                response = table.query(
                    ScanIndexForward=False,
                    KeyConditionExpression=
                        Key('device_id').eq(device_id) &
                        Key('timestamp').between(start_time, end_time),
                    ExclusiveStartKey=last_evaluated_key
                )
            else:
                response = table.query(
                    ScanIndexForward=False,
                    KeyConditionExpression=
                        Key('device_id').eq(device_id) &
                        Key('timestamp').between(start_time, end_time)
                )
            last_evaluated_key = response.get('LastEvaluatedKey')
            for item in response['Items']:
                ts = int(item['timestamp'])
                ts_list.add(ts)

                for path in req['path']:
                    value = get_obj_path(item['device_data'], path)
                    if value is None:
                        evaluate_message += 'Cannot get %s for %s at time %d!\n' % (path, device_name, ts)
                        value = 0

                    if isinstance(value, Decimal): value = float(value)
                    readings['%s.%s' % (device_name, path)][ts] = value
    """

    sql = 'SELECT timestamp, value_decimal FROM data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND device_id = %s AND field = %s'

    for device_name, req in device_reqs.items():
        device_id = req['id']
        for path in req['path']:
            conn = get_tsdb_conn()
            cursor = conn.cursor()
            cursor.execute(sql, (start_time, end_time, device_id, path))
            rows = cursor.fetchall()
            cursor.close()
            for row in rows:
                ts = int(row[0].timestamp() * 1000)
                value = row[1]
                ts_list.add(ts)
                readings['%s.%s' % (device_name, path)][ts] = value

    # Populate the evaluation context
    array_dict = dict()
    ts_list = sorted(list(ts_list))
    for path, path_dict in readings.items():
        array_dict[path] = []
        for ts in ts_list:
            value = path_dict.get(ts, None)
            if value is None:
                evaluate_message += 'Cannot get %s at timestamp %d!\n' % (path, ts)
                value = 0
            array_dict[path].append(value)
        array_dict[path] = np.array(array_dict[path])

    # Perform the evaluation
    try:
        result_time_series = engine.evaluate(array_dict)
    except Exception as e:
        return err_json(str(e))

    # Evaluate aggregrate function if specified
    if 'agg_function' in data:
        agg = data['agg_function']
        fn = agg_functions[agg]
        value = fn(result_time_series)
        ret = {
            'status': 'ok',
            'value': value,
            'message': evaluate_message
        }
        if agg in arg_functions:
            idx = arg_functions[agg](result_time_series)
            ts = ts_list[idx]
            ret['timestamp'] = ts

        return jsonify(ret)

    result = []
    if 'average' in data and len(ts_list) > 0:
        # Perform average operation if specified
        avg_span = int(data['average'])
        start_ts = ts_list[0]
        data_span = []
        for i in range(len(ts_list)):
            current_ts = ts_list[i]
            if current_ts - start_ts >= avg_span:
                # Aggregate if cumulative time exceeds timespan
                avg = np.mean(np.array(data_span))
                result.append({
                    'timestamp': start_ts,
                    'value': avg
                })
                # Reset current window
                data_span = [result_time_series[i]]
                start_ts = current_ts
            else:
                data_span.append(result_time_series[i])
        # Pick up remaining data
        avg = np.mean(np.array(data_span))
        result.append({
            'timestamp': start_ts,
            'value': avg
        })
    else:
        # Return whole time series data
        for i in range(len(ts_list)):
            result.append({
                'timestamp': ts_list[i],
                'value': result_time_series[i]
            })
    return jsonify({
        'status': 'ok',
        'data': result,
        'message': evaluate_message,
    })