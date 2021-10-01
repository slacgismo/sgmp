from flask import Blueprint, jsonify, request
import boto3
from boto3.dynamodb.conditions import Key

from utils.functions import err_json
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

    return jsonify({
        'status': 'ok'
    })
