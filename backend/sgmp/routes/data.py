from flask import Blueprint, json, jsonify, request
import numpy as np

from models.analytics import Analytics
from models.device import Device

from utils.functions import err_json, get_obj_path
from utils.analytics_engine import AnalyticsEngine
from utils.tsdb import get_tsdb_conn
from utils.auth import require_auth

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
@require_auth()
def data_read():
    data = request.json

    # Verify data
    if 'start_time' not in data:
        return err_json('bad request')
    if 'end_time' not in data:
        return err_json('bad request')
    if 'type' not in data:
        return err_json('bad request')
    
    # TODO: Back-compatibility, remove this once frontend has migrated
    if 'house_id' not in data:
        data['house_id'] = '1'

    if data['type'] != 'device' and data['type'] != 'analytics':
        return err_json('bad request')

    # Process device data read
    if data['type'] == 'device':
        # TODO: Remove reference to device_id
        if 'device_id' not in data and 'device_name' not in data:
            return err_json('bad request')
        
        start_time = float(data['start_time']) / 1000
        end_time = float(data['end_time']) / 1000
        house_id = int(data['house_id'])

        # TODO: Back-compatibility, remove this branch
        if 'device_id' in data:
            device_id = int(data['device_id'])
            sql = 'SELECT timestamp, field, value_decimal, value_text FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND device_id = %s ORDER BY timestamp ASC'
        
            conn = get_tsdb_conn()
            cursor = conn.cursor()
            cursor.execute(sql, (start_time, end_time, device_id))
            rows = cursor.fetchall()
            cursor.close()
        else:
            device_name = data['device_name']
            sql = 'SELECT timestamp, field, value_decimal, value_text FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s ORDER BY timestamp ASC'
        
            conn = get_tsdb_conn()
            cursor = conn.cursor()
            cursor.execute(sql, (start_time, end_time, house_id, device_name))
            rows = cursor.fetchall()
            cursor.close()

        ts_dict = dict()
        for row in rows:
            ts = int(row[0].timestamp() * 1000)
            if ts not in ts_dict:
                ts_dict[ts] = dict()
            field = row[1]
            if row[2] is not None:
                ts_dict[ts][field] = row[2]
            else:
                ts_dict[ts][field] = row[3]

        lst = []
        for ts, fields in ts_dict.items():
            lst.append({
                'timestamp': ts,
                'data': fields
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

        # For single formula case
        if isinstance(formula, str):
            formulas = [formula]
        else:
            formulas = formula

        results = []
        for formula in formulas:
            # Parse the formula expression
            engine = AnalyticsEngine()
            try:
                stack = engine.parse_expression(formula)
            except Exception as e:
                results.append({'status': 'error', 'message': 'cannot parse: %s' % e})
                continue
            
            # Verify all devices are present
            idents = engine.collect_identifiers()

            if len(stack) == 1 and len(idents) == 1:
                # Use optimized queries
                results.append(process_single_value_read(data, idents[0]))
            else:
                # Use normal procedure
                results.append(process_expression(data, engine, stack, idents))

        if len(results) == 1:
            return jsonify(results[0])
        else:
            return jsonify({
                'status': 'ok',
                'results': results
            })

    return jsonify({
        'status': 'ok'
    })

def process_single_value_read(data, ident):
    start_time = float(data['start_time']) / 1000
    end_time = float(data['end_time']) / 1000
    house_id = int(data['house_id'])
    components = ident.split('.')
    device_name = components[0]

    # Verify device exists
    device = Device.query.filter_by(name=device_name, house_id=house_id).first()
    if device is None:
        return {'status': 'error',
            'message': 'device %s does not exist (evaluating %s)'
            % (device_name, ident)}

    # Field name
    field = '.'.join(components[1:])

    # Special case #1: aggregate function
    if 'agg_function' in data:
        agg = data['agg_function']

        # Execute query
        conn = get_tsdb_conn()
        cursor = conn.cursor()

        if agg == 'min':
            sql = 'SELECT DISTINCT ON (device_id) timestamp, value_decimal FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s ORDER BY device_id, value_decimal ASC'
            cursor.execute(sql, (start_time, end_time, house_id, device_name, field))
            row = cursor.fetchone()
            cursor.close()
            if row is None:
                return {'status': 'error', 'message': 'no data available'}

            return {
                'status': 'ok',
                'timestamp': int(row[0].timestamp() * 1000),
                'value': row[1]
            }
        elif agg == 'max':
            sql = 'SELECT DISTINCT ON (device_id) timestamp, value_decimal FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s ORDER BY device_id, value_decimal DESC'
            cursor.execute(sql, (start_time, end_time, house_id, device_name, field))
            row = cursor.fetchone()
            cursor.close()
            if row is None:
                return {'status': 'error', 'message': 'no data available'}

            return {
                'status': 'ok',
                'timestamp': int(row[0].timestamp() * 1000),
                'value': row[1]
            }
        elif agg == 'avg':
            sql = 'SELECT AVG(value_decimal) FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s'
            cursor.execute(sql, (start_time, end_time, house_id, device_name, field))
            row = cursor.fetchone()
            cursor.close()
            if row is None:
                return {'status': 'error', 'message': 'no data available'}
                
            return {
                'status': 'ok',
                'value': row[0]
            }

    # Execute query
    conn = get_tsdb_conn()
    cursor = conn.cursor()

    if 'average' in data:
        # Special case #2: average bucket
        timespan = str(data['average']) + ' milliseconds'
        sql = 'SELECT time_bucket(%s, timestamp) AS time, AVG(value_decimal) AS average FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s GROUP BY time ORDER BY time ASC'
        cursor.execute(sql, (timespan, start_time, end_time, house_id, device_name, field))
    else:
        # Construct query
        sql = 'SELECT timestamp, value_decimal FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s ORDER BY timestamp ASC'
        cursor.execute(sql, (start_time, end_time, house_id, device_name, field))

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

    return {
        'status': 'ok',
        'data': result
    }

def process_expression(data, engine, stack, idents):
    evaluate_message = 'Identifiers: '
    device_reqs = dict()
    start_time = float(data['start_time']) / 1000
    end_time = float(data['end_time']) / 1000
    house_id = int(data['house_id'])

    for ident in idents:
        evaluate_message += ident
        evaluate_message += ', '
        components = ident.split('.')
        device_name = components[0]
        path = '.'.join(components[1:])
        if device_name in device_reqs:
            device_reqs[device_name].add(path)
            continue
        
        device = Device.query.filter_by(name=device_name, house_id=house_id).first()
        if device is None:
            return {'status': 'error',
                'message': 'device %s does not exist (evaluating %s)'
                % (device_name, ident)}
        
        device_reqs[device_name] = set([path])
    
    evaluate_message += '\n'

    readings = dict()
    for name, req in device_reqs.items():
        device_reqs[name] = list(req)
        for path in req:
            readings['%s.%s' % (name, path)] = dict()
        
    # Grab all data
    ts_list = set()
    sql = 'SELECT timestamp, value_decimal FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s'

    for device_name, req in device_reqs.items():
        for path in req:
            conn = get_tsdb_conn()
            cursor = conn.cursor()
            cursor.execute(sql, (start_time, end_time, house_id, device_name, path))
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
        return {'status': 'error', 'message': 'error during evaluation: %s' % str(e)}

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

        return ret

    result = []
    if 'average' in data and len(ts_list) > 0:
        # Perform average operation if specified
        avg_span = int(data['average'])
        buckets = {}
        bucket_ts = []
        # Put values into buckets
        for i in range(len(ts_list)):
            current_ts = ts_list[i]
            # Truncate by the average window span
            trunc_ts = current_ts - (current_ts % avg_span)
            if trunc_ts not in buckets:
                buckets[trunc_ts] = []
                bucket_ts.append(trunc_ts)

            buckets[trunc_ts].append(result_time_series[i])

        # Make sure output is sorted
        bucket_ts = sorted(bucket_ts)

        # Calculate mean for each bucket
        for trunc_ts in bucket_ts:
            arr = np.array(buckets[trunc_ts])
            avg = np.mean(arr)
            result.append({
                'timestamp': trunc_ts,
                'value': avg
            })
    else:
        # Return whole time series data
        for i in range(len(ts_list)):
            result.append({
                'timestamp': ts_list[i],
                'value': result_time_series[i]
            })
    return {
        'status': 'ok',
        'data': result,
        'message': evaluate_message,
    }