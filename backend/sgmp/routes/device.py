from flask import Blueprint, jsonify, request
import json

from models.device import Device
from models.house import House
from models.shared import db

from utils.functions import err_json
from utils.auth import check_house_access, check_house_or_device_access, require_auth

api_device = Blueprint('device', __name__)

@api_device.route('/list', methods=['POST'])
@require_auth()
@check_house_access()
def device_list():
    data = request.json

    if 'house_id' not in data:
        return err_json('bad request')

    # List all devices for the give house_id
    devices = Device.query.filter_by(house_id=int(data['house_id'])).all()
    
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
@check_house_or_device_access()
def device_details():
    data = request.json

    # Variant 1: supplying device_id
    if 'device_id' in data:
        device_id = int(data['device_id'])

        # Read data from database
        device = Device.query.filter_by(device_id=device_id).first()
        if device is None:
            return err_json('device not found')

        return jsonify({
            'status': 'ok',
            'device': {
                'device_id': device.device_id,
                'house_id': device.house_id,
                'name': device.name,
                'description': device.description,
                'type': device.type,
                'config': json.loads(device.config)
            }
        })
    # Variant 2: supplying house_id and device name
    elif 'house_id' in data and 'name' in data:
        house_id = int(data['house_id'])
        name = data['name']

        # Read data from database
        device = Device.query.filter_by(house_id=house_id, name=name).first()
        if device is None:
            return err_json('device not found')

        return jsonify({
            'status': 'ok',
            'device': {
                'device_id': device.device_id,
                'name': device.name,
                'description': device.description,
                'type': device.type,
                'config': json.loads(device.config)
            }
        })
    else:
        return err_json('bad request')

@api_device.route('/create', methods=['POST'])
@require_auth('admin')
@check_house_access()
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
    if 'house_id' not in data:
        return err_json('bad request')

    # Check house exists
    house_id = int(data['house_id'])
    count = House.query.filter_by(house_id=house_id).count()
    if count == 0:
        return err_json('house does not exist')

    # Check name does not exist
    count = Device.query.filter_by(name=data['name'], house_id=house_id).count()
    if count > 0:
        return err_json('device exists')

    # Convert config to JSON string
    config_json = json.dumps(data['config'])

    # Save the data
    device = Device(
        name=data['name'],
        description=data['description'],
        type=data['type'],
        house_id=house_id,
        config=config_json
    )
    db.session.add(device)
    db.session.commit()

    return jsonify({'status': 'ok'})

@api_device.route('/update', methods=['POST'])
@require_auth('admin')
@check_house_or_device_access()
def device_update():
    data = request.json

    # Variant 1: supplying device_id
    if 'device_id' in data:
        device_id = int(data['device_id'])
        
        # Read data from database
        device = Device.query.filter_by(device_id=device_id).first()
        if device is None:
            return err_json('device not found')
    # Variant 2: supplying house_id and device name
    elif 'house_id' in data and 'name' in data:
        house_id = int(data['house_id'])
        name = data['name']
        
        # Read data from database
        device = Device.query.filter_by(house_id=house_id, name=name).first()
        if device is None:
            return err_json('device not found')
    else:
        return err_json('bad request')

    # Update given fields
    if 'description' in data:
        device.description = data['description']
    if 'config' in data:
        config_json = json.dumps(data['config'])
        device.config = config_json

    db.session.commit()
    return jsonify({'status': 'ok'})

@api_device.route('/delete', methods=['POST'])
@require_auth('admin')
@check_house_or_device_access()
def device_delete():
    data = request.json

    # Variant 1: supplying device_id
    if 'device_id' in data:
        if isinstance(data['device_id'], int):
            device_ids = [data['device_id']]
        elif isinstance(data['device_id'], str):
            device_ids = [int(data['device_id'])]
        elif isinstance(data['device_id'], list):
            device_ids = data['device_id']
        else:
            return err_json('bad request')

        for device_id in device_ids:
            # Delete data from database
            Device.query.filter_by(device_id=device_id).delete()

        db.session.commit()
        return jsonify({'status': 'ok'})
    # Variant 2: supplying house_id and device name
    elif 'house_id' in data and 'name' in data:
        house_id = int(data['house_id'])
        if isinstance(data['name'], str):
            names = [data['name']]
        elif isinstance(data['name'], list):
            names = data['name']
        else:
            return err_json('bad request')

        for name in names:
            # Delete data from database
            Device.query.filter_by(house_id=house_id, name=name).delete()

        db.session.commit()
        return jsonify({'status': 'ok'})
    else:
        return err_json('bad request')
