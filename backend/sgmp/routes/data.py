from decimal import Decimal
from flask import Blueprint, jsonify, request
import boto3
from boto3.dynamodb.conditions import Key
import numpy as np

from models.analytics import Analytics
from models.device import Device

from utils.functions import err_json, get_obj_path
from utils.analytics_engine import AnalyticsEngine
import utils.config as config

api_data = Blueprint('data', __name__)

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
        if 'analytics_id' not in data:
            return err_json('bad request')

        start_time = int(data['start_time'])
        end_time = int(data['end_time'])
        analytics_id = int(data['analytics_id'])

        analytics = Analytics.query.filter_by(analytics_id=analytics_id).first()
        if analytics is None:
            return err_json('analytics not found')

        # Parse the formula expression
        evaluate_message = ''
        engine = AnalyticsEngine()
        formula = analytics.formula
        try:
            stack = engine.parse_expression(formula)
        except Exception as e:
            return err_json(str(e))

        # Verify all devices are present
        device_reqs = dict()
        idents = engine.collect_identifiers()
        evaluate_message += 'Identifiers: '
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

        dynamodb = boto3.resource('dynamodb', region_name='us-west-1')
        table = dynamodb.Table(config.DYNAMODB_TALBE)
        for device_name, req in device_reqs.items():
            device_id = req['id']
            response = table.query(
                ScanIndexForward=False,
                KeyConditionExpression=
                    Key('device_id').eq(device_id) &
                    Key('timestamp').between(start_time, end_time)
            )
            lst = []
            for item in response['Items']:
                ts = int(item['timestamp'])
                ts_list.add(ts)

                for path in req['path']:
                    value = get_obj_path(item['device_data'], path)
                    if value is None:
                        evaluate_message += 'Cannot get %s for %s at time %d!\n' % ('.'.join(path), device_name, ts)
                        value = 0

                    if isinstance(value, Decimal): value = float(value)
                    readings['%s.%s' % (device_name, path)][ts] = value

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

        try:
            result_time_series = engine.evaluate(array_dict)
        except Exception as e:
            return err_json(str(e))

        result = []
        for i in range(len(ts_list)):
            result.append({
                'timestamp': ts_list[i],
                'value': result_time_series[i]
            })
        return jsonify({
            'status': 'ok',
            'result': result,
            'message': evaluate_message,
        })

    return jsonify({
        'status': 'ok'
    })
