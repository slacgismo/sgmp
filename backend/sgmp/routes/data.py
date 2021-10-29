from typing import Dict, Sequence, Tuple
from flask import Blueprint, json, jsonify, request
import traceback
import numpy as np
import pandas as pd

from models.analytics import Analytics
from models.device import Device
from models.identifier_view import IdentifierView

from utils.functions import err_json, get_obj_path
from utils.analytics_engine import AnalyticsEngine
from utils.logging import get_logger
from utils.tsdb import get_tsdb_conn
from utils.auth import require_auth

logger = get_logger('data')
api_data = Blueprint('data', __name__)

agg_functions = {
    'min': lambda arr: arr.min(),
    'max': lambda arr: arr.max(),
    'avg': lambda arr: arr.mean()
}
arg_functions = {
    'min': lambda arr: arr.idxmin(),
    'max': lambda arr: arr.idxmax()
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
            sql = 'SELECT timestamp, field, value_decimal, value_text FROM data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND device_id = %s ORDER BY timestamp ASC'
        
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
        if 'analytics_name' not in data and 'formula' not in data:
            return err_json('bad request')
        if 'agg_function' in data:
            if data['agg_function'] not in agg_functions:
                return err_json('agg_function is invalid')
        if 'agg_function' in data and 'average' in 'data':
            return err_json('bad request')

        house_id = int(data['house_id'])
        formulas = list()
        identifier_views = None

        # If fine-level data is requested, skip continuous aggregation
        if 'fine' not in data:
            # Pull TimescaleDB continuous aggregation list
            views = IdentifierView.query.filter_by(house_id=house_id).all()
            identifier_views = {}
            for view in views:
                identifier_views[view.identifier] = view.view_name

        if 'analytics_name' in data:
            # Check all analytics objects exist
            analytics_names = []
            if isinstance(data['analytics_name'], list):
                analytics_names = data['analytics_name']
            else:
                analytics_names = [data['analytics_name']]

            # Retrieve Analytics object
            for analytics_name in analytics_names:
                analytics = Analytics.query.filter_by(house_id=house_id, name=analytics_name).first()
                if analytics is None:
                    return err_json('analytics %s not found' % analytics_name)
                formulas.append(analytics.formula)
        else:
            formula = data['formula']

            # For single formula case
            if isinstance(formula, str):
                formulas = [formula]
            else:
                formulas = formula

        results = []
        for formula in formulas:
            try:
                results.append(evaluate_forumla(data, formula, identifier_views))
            except Exception as e:
                logger.info('Error occurred during evaluation of %s: %s' % (formula, traceback.format_exc()))
                return jsonify({
                    'status': 'error',
                    'message': 'exception raised during evaluation of %s: %s' % (formula, e)
                })

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

def evaluate_forumla(data, formula, identifier_views):
    # Parse the formula expression
    engine = AnalyticsEngine()
    try:
        stack = engine.parse_expression(formula)
    except Exception as e:
        return {'status': 'error', 'message': 'cannot parse: %s' % e}
    
    # Verify all devices are present
    idents = engine.collect_identifiers()

    if len(stack) == 1 and len(idents) == 1 and idents[0].split('.')[0] != 'analytics':
        # Use optimized queries
        view_name = None
        if identifier_views is not None:
            if idents[0] in identifier_views:
                view_name = identifier_views[idents[0]]
        return process_single_value_read(data, idents[0], view_name)
    else:
        # Use normal procedure
        return process_expression(data, engine, stack, idents, identifier_views)

def process_single_value_read(data, ident, view_name):
    start_time = float(data['start_time']) / 1000
    end_time = float(data['end_time']) / 1000
    house_id = int(data['house_id'])
    components = ident.split('.')
    device_name = components[0]

    # Verify device exists
    device = Device.query.filter_by(name=device_name, house_id=house_id).first()
    if device is None:
        raise Exception('device %s does not exist (evaluating %s)' % (device_name, ident))

    # Field name
    field = '.'.join(components[1:])

    # Special case #1: aggregate function
    if 'agg_function' in data:
        agg = data['agg_function']

        # Execute query
        conn = get_tsdb_conn()
        cursor = conn.cursor()

        if agg == 'min':
            if view_name is None:
                sql = 'SELECT DISTINCT ON (device_name) timestamp, value_decimal FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s ORDER BY device_name, value_decimal ASC'
                cursor.execute(sql, (start_time, end_time, house_id, device_name, field))
            else:
                sql = 'SELECT time, average FROM {} WHERE time BETWEEN to_timestamp(%s) AND to_timestamp(%s) ORDER BY average ASC'.format(view_name)
                cursor.execute(sql, (start_time, end_time))
            row = cursor.fetchone()
            cursor.close()
            if row is None:
                raise Exception('no data available for %s' % ident)

            return {
                'status': 'ok',
                'timestamp': int(row[0].timestamp() * 1000),
                'value': row[1]
            }
        elif agg == 'max':
            if view_name is None:
                sql = 'SELECT DISTINCT ON (device_name) timestamp, value_decimal FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s ORDER BY device_name, value_decimal DESC'
                cursor.execute(sql, (start_time, end_time, house_id, device_name, field))
            else:
                sql = 'SELECT time, average FROM {} WHERE time BETWEEN to_timestamp(%s) AND to_timestamp(%s) ORDER BY average DESC'.format(view_name)
                cursor.execute(sql, (start_time, end_time))
            row = cursor.fetchone()
            cursor.close()
            if row is None:
                raise Exception('no data available for %s' % ident)

            return {
                'status': 'ok',
                'timestamp': int(row[0].timestamp() * 1000),
                'value': row[1]
            }
        elif agg == 'avg':
            if view_name is None:
                sql = 'SELECT AVG(value_decimal) FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s'
                cursor.execute(sql, (start_time, end_time, house_id, device_name, field))
            else:
                sql = 'SELECT AVG(average) FROM {} WHERE time BETWEEN to_timestamp(%s) AND to_timestamp(%s)'.format(view_name)
                cursor.execute(sql, (start_time, end_time))
            row = cursor.fetchone()
            cursor.close()
            if row is None:
                raise Exception('no data available for %s' % ident)
                
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
        if view_name is None:
            sql = 'SELECT time_bucket(%s, timestamp) AS time, AVG(value_decimal) AS average FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s GROUP BY time ORDER BY time ASC'
            cursor.execute(sql, (timespan, start_time, end_time, house_id, device_name, field))
        else:
            sql = 'SELECT time_bucket(%s, time) AS bucket, AVG(average) AS average FROM {} WHERE time BETWEEN to_timestamp(%s) AND to_timestamp(%s) GROUP BY bucket ORDER BY bucket ASC'.format(view_name)
            cursor.execute(sql, (timespan, start_time, end_time))
    else:
        # Construct query
        if view_name is None:
            sql = 'SELECT timestamp, value_decimal, value_text FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field = %s ORDER BY timestamp ASC'
            cursor.execute(sql, (start_time, end_time, house_id, device_name, field))
        else:
            sql = 'SELECT time, average FROM {} WHERE time BETWEEN to_timestamp(%s) AND to_timestamp(%s) ORDER BY time ASC'.format(view_name)
            cursor.execute(sql, (start_time, end_time))

    # Retrieve results
    rows = cursor.fetchall()
    cursor.close()

    result = []
    for row in rows:
        timestamp = int(row[0].timestamp() * 1000)
        value = row[1] if row[1] is not None else row[2]
        result.append({
            'timestamp': timestamp,
            'value': value
        })

    return {
        'status': 'ok',
        'data': result
    }

def process_expression(data, engine, stack, idents, ident_view):
    evaluate_message = ''
    start_time = float(data['start_time']) / 1000
    end_time = float(data['end_time']) / 1000
    house_id = int(data['house_id'])

    raw_data_idents = []
    ca_idents = []
    analytics_idents = []
    if ident_view is None: ident_view = {}
    for ident in idents:
        components = ident.split('.')
        if ident in ident_view:
            ca_idents.append(ident)
        elif components[0] != 'analytics':
            raw_data_idents.append(ident)
        else:
            analytics_idents.append(ident)

    msg, ts = _fetch_continuous_aggregation(start_time, end_time, ca_idents, ident_view)
    evaluate_message += msg + '\n'
    array_dict = ts

    msg, ts = _fetch_context(start_time, end_time, house_id, raw_data_idents)
    evaluate_message += msg + '\n'
    array_dict = {**array_dict, **ts}

    msg, ts = _fetch_analytics(start_time, end_time, house_id, analytics_idents, ident_view)
    evaluate_message += msg + '\n'
    array_dict = {**array_dict, **ts}


    # Perform the evaluation
    try:
        result_time_series = engine.evaluate(array_dict)
    except Exception as e:
        raise Exception('error during evaluation of expression: %s' % e)

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
            ts = arg_functions[agg](result_time_series)
            ret['timestamp'] = ts

        return ret

    result = []
    if isinstance(result_time_series, pd.Series):
        if 'average' in data:
            # Bin timestamp if requested
            avg_span = int(data['average'])
            result_time_series = result_time_series.groupby(lambda ts: (ts - (ts % avg_span))).mean()

        # Restructure return data
        for timestamp, value in result_time_series.items():
            result.append({
                'timestamp': timestamp,
                'value': value
            })

    return {
        'status': 'ok',
        'data': result,
        'message': evaluate_message,
    }

def _fetch_analytics(start_time: float, end_time: float, house_id: int, idents: Sequence[str], ident_view: Dict[str, str]) -> Tuple[str, pd.Series]:
    array_dict = dict()
    evaluate_message = 'Nested analytic identifiers:\n'

    # Common context during evaluation of each analytics item
    evaluate_context = {
        'start_time': int(start_time * 1000),
        'end_time': int(end_time * 1000),
        'house_id': house_id
    }

    # Evaluate all identifiers
    for ident in idents:
        # Fetch formula of the analytics
        evaluate_message += ident + '\n'
        analytics_name = '.'.join(ident.split('.')[1:])
        analytics = Analytics.query.filter_by(house_id=house_id, name=analytics_name).first()
        if analytics is None:
            raise Exception('analytics %s does not exist!' % analytics_name)
        
        formula = analytics.formula
        try:
            result = evaluate_forumla(evaluate_context, formula, ident_view)
        except Exception as e:
            raise Exception('error during evaluation of %s (%s): %s' % (ident, formula, e))
        timestamps = []
        values = []
        if 'data' not in result:
            raise Exception('evaluation of %s did not return any result!' % analytics_name)
        
        for row in result['data']:
            timestamps.append(row['timestamp'])
            values.append(row['value'])

        array_dict[ident] = pd.Series(values, index=timestamps)
        
    return evaluate_message, array_dict


def _fetch_context(start_time: float, end_time: float, house_id: int, idents: Sequence[str]) -> Tuple[str, Dict[str, pd.Series]]:
    array_dict = dict()
    evaluate_message = 'Raw data identifiers: '
    device_reqs = dict()

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
            raise Exception('device %s does not exist (evaluating %s)' % (device_name, ident))
        
        device_reqs[device_name] = set([path])
    
    evaluate_message += '\n'
        
    # Grab all data
    conn = get_tsdb_conn()
    array_dict = dict()
    sql = 'SELECT timestamp, field, value_decimal, value_text AS value FROM house_data WHERE timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id = %s AND device_name = %s AND field IN %s'

    for device_name, req in device_reqs.items():
        # Prepare data structure for each device
        readings = {}
        timestamps = {}
        for path in req:
            readings[path] = []
            timestamps[path] = []

        # Read all required field for this device at once
        req_tuple = tuple(req)
        cursor = conn.cursor()
        cursor.execute(sql, (start_time, end_time, house_id, device_name, req_tuple))
        rows = cursor.fetchall()
        cursor.close()
        for row in rows:
            ts = int(row[0].timestamp() * 1000)
            field = row[1]
            value = row[2] if row[2] is not None else row[3]
            timestamps[field].append(ts)
            readings[field].append(value)

        for path in req:
            ts = pd.Series(readings[path], index=timestamps[path])
            array_dict['%s.%s' % (device_name, path)] = ts

    return (evaluate_message, array_dict)

def _fetch_continuous_aggregation(start_time: float, end_time: float, idents: Sequence[str], ident_view: Dict[str, str]) -> Tuple[str, Dict[str, pd.Series]]:
    array_dict = dict()
    evaluate_message = 'Using continuous aggregations:\n'
    conn = get_tsdb_conn()
    for ident in idents:
        view_name = ident_view[ident]
        evaluate_message += '%s => %s\n' % (ident, view_name)

        sql = 'SELECT time, average FROM {} WHERE time BETWEEN to_timestamp(%s) AND to_timestamp(%s)'.format(view_name)
        cursor = conn.cursor()
        cursor.execute(sql, (start_time, end_time))
        rows = cursor.fetchall()
        cursor.close()

        readings = []
        timestamps = []
        for row in rows:
            ts = int(row[0].timestamp() * 1000)
            value = row[1]
            timestamps.append(ts)
            readings.append(value)

        array_dict[ident] = pd.Series(readings, index=timestamps).sort_index(ascending=False)

    return (evaluate_message, array_dict)
