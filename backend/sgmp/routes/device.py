from flask import Blueprint, jsonify, request
import json

from models.device import Device
from models.shared import db

from utils.functions import err_json
from utils.iot import publish
from utils.auth import require_auth

api_device = Blueprint('device', __name__)

@api_device.route('/list', methods=['GET'])
@require_auth()
def device_list():
    # Read devices from database
    devices = Device.query.all()
    ret = []
    for device in devices:
        ret.append({
            'device_id': device.device_id,
            'name': device.name,
            'description': device.description,
            'type': device.type
        })
    
    return jsonify({'status': 'ok', 'devices': ret})

@api_device.route('/details', methods=['POST'])
@require_auth()
def device_details():
    data = request.json

    # Validate input
    if 'device_id' not in data:
        return err_json('bad request')
    device_id = int(data['device_id'])

    # Read data from database
    device = Device.query.filter_by(device_id=device_id).first()
    if device is None:
        return err_json('device not found')

    return jsonify({
        'status': 'ok',
        'device': {
            'name': device.name,
            'description': device.description,
            'type': device.type,
            'config': json.loads(device.config)
        }
    })

@api_device.route('/create', methods=['POST'])
@require_auth('admin')
def device_create():
    data = request.json

    # Validate input
    if 'name' not in data:
        return err_json('bad request')
    if 'description' not in data:
        return err_json('bad request')
    if 'type' not in data:
        return err_json('bad request')
    if 'config' not in data:
        return err_json('bad request')

    # Check name does not exist
    count = Device.query.filter_by(name=data['name']).count()
    if count > 0:
        return err_json('device exists')

    # Convert config to JSON string
    config_json = json.dumps(data['config'])

    # Save the data
    device = Device(
        name=data['name'],
        description=data['description'],
        type=data['type'],
        config=config_json
    )
    db.session.add(device)
    db.session.commit()

    return jsonify({'status': 'ok'})

@api_device.route('/delete', methods=['POST'])
@require_auth('admin')
def device_delete():
    data = request.json

    # Validate input
    if 'device_id' not in data:
        return err_json('bad request')
    device_id = int(data['device_id'])

    # Delete data from database
    Device.query.filter_by(device_id=device_id).delete()
    db.session.commit()

    return jsonify({'status': 'ok'})

@api_device.route('/sync', methods=['GET'])
@require_auth('admin')
def device_sync():
    # This is the data to be published
    data = []

    # Retrieve all devices
    devices = Device.query.all()
    for device in devices:
        data.append({
            'device_id': device.device_id,
            'name': device.name,
            'type': device.type,
            'config': json.loads(device.config)
        })

    # Publish data as JSON string
    publish_str = json.dumps(data)
    publish('gismolab_sgmp_config/devices', publish_str)

    return jsonify({'status': 'ok'})