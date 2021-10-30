import json
from flask import Blueprint, jsonify, request, g

from models.house import House
from models.device import Device
from models.shared import db

from utils.functions import err_json, get_boto3_client
from utils.auth import require_auth
from utils.iot import publish
from utils.logging import get_logger

import utils.config as config

api_house = Blueprint('house', __name__)
logger = get_logger('house')

@api_house.route('/list', methods=['GET'])
@require_auth()
def house_list():
    # For admin, read all house from database
    if 'admin' in g.user['roles']:
        query_result = House.query.all()
        ret = []
        for row in query_result:
            ret.append({
                'house_id': row.house_id,
                'name': row.name,
                'description': row.description
            })
    else:
        house_id = g.user['house_id']
        ret = []
        house = House.query.filter_by(house_id=house_id).first()
        if house is None:
            return jsonify({
                'status': 'error',
                'message': 'house not found, please contact administrator'
            })
        ret.append({
            'house_id': house.house_id,
            'name': house.name,
            'description': house.description
        })
    
    return jsonify({'status': 'ok', 'houses': ret})

@api_house.route('/create', methods=['POST'])
@require_auth('admin')
def house_create():
    data = request.json

    # Validate input
    if 'name' not in data:
        return err_json('bad request')
    if 'description' not in data:
        return err_json('bad request')

    # Check name does not exist
    count = House.query.filter_by(name=data['name']).count()
    if count > 0:
        return err_json('house exists')

    # Save the data
    data = House(
        name=data['name'],
        description=data['description'],
        cert_arn=''
    )
    db.session.add(data)
    db.session.commit()
    db.session.refresh(data, attribute_names=['house_id'])

    # Fetch AWS Account ID for ARN usage
    account_id = get_boto3_client('sts').get_caller_identity().get('Account')

    # Create Thing on AWS IoT Core
    client = get_boto3_client('iot')
    thing_name = '%s_house_%d' % (config.DEPLOYMENT_NAME, data.house_id)
    try:
        client.create_thing(thingName=thing_name)

        resp = client.create_keys_and_certificate(setAsActive=True)
        arn = resp['certificateArn']
        public_key = resp['keyPair']['PublicKey']
        private_key = resp['keyPair']['PrivateKey']
        cert = resp['certificatePem']

        client.attach_policy(policyName=('%s_edge' % config.DEPLOYMENT_NAME), target=arn)
        client.attach_thing_principal(thingName=thing_name, principal=arn)
        client.attach_thing_principal(thingName=thing_name, principal='arn:aws:iot:%s:%s:cert/%s' % (config.AWS_REGION, account_id, config.IOT_CERT_ID))
    except Exception as e:
        print('error creating thing: %s' % e)
        return err_json('internal server error')

    data.cert_arn = arn
    db.session.commit()

    return jsonify({
        'status': 'ok',
        'house_id': data.house_id,
        'cert': cert,
        'private_key': private_key,
        'public_key': public_key
    })

@api_house.route('/update', methods=['POST'])
@require_auth('admin')
def house_update():
    data = request.json

    # Validate input
    if 'house_id' not in data:
        return err_json('bad request')

    # Retrieve row
    row = House.query.filter_by(house_id=int(data['house_id'])).first()
    if row is None:
        return err_json('house not found')

    if 'description' in data:
        row.description = data['description']
    db.session.commit()

    return jsonify({'status': 'ok'})

@api_house.route('/delete', methods=['POST'])
@require_auth(['admin'])
def house_delete():
    data = request.json

    # Validate input
    if 'house_id' not in data:
        return err_json('bad request')
    house_id = int(data['house_id'])

    # Check that no devices exist under the house
    count = Device.query.filter_by(house_id=house_id).count()
    if count > 0:
        return err_json('house is not empty')

    # Check for existance
    house = House.query.filter_by(house_id=house_id).first()
    if house is None:
        return err_json('house not found')

    # Fetch AWS Account ID for ARN usage
    account_id = get_boto3_client('sts').get_caller_identity().get('Account')

    # Revoke keys
    client = get_boto3_client('iot')
    thing_name = '%s_house_%d' % (config.DEPLOYMENT_NAME, house_id)
    if len(house.cert_arn) > 0:
        cert_id = house.cert_arn.split('/')[1]
        try:
            client.detach_thing_principal(thingName=thing_name, principal=house.cert_arn)
            client.detach_thing_principal(thingName=thing_name, principal='arn:aws:iot:%s:%s:cert/%s' % (config.AWS_REGION, account_id, config.IOT_CERT_ID))
            client.detach_policy(policyName=('%s_edge' % config.DEPLOYMENT_NAME), target=house.cert_arn)
            client.update_certificate(certificateId=cert_id, newStatus='INACTIVE')
            client.delete_certificate(certificateId=cert_id)
        except Exception as e:
            print('error revoking certificate: %s' % e)

    # Delete Thing
    try:
        client.delete_thing(thingName=thing_name)
    except Exception as e:
        print('error deleting thing: %s' % e)

    # Delete data from database
    House.query.filter_by(house_id=house_id).delete()
    db.session.commit()

    return jsonify({'status': 'ok'})

@api_house.route('/generateKeys', methods=['POST'])
@require_auth('admin')
def generate_keys():
    data = request.json

    # Validate input
    if 'house_id' not in data:
        return err_json('bad request')
    house_id = int(data['house_id'])

    house = House.query.filter_by(house_id=house_id).first()
    if house is None:
        return err_json('house does not exist')

    client = get_boto3_client('iot')
    thing_name = '%s_house_%d' % (config.DEPLOYMENT_NAME, house_id)
    if len(house.cert_arn) > 0:
        cert_arn = house.cert_arn
        cert_id = cert_arn.split('/')[1]
    else:
        cert_id = ''

    # Create new set of credential
    try:
        resp = client.create_keys_and_certificate(setAsActive=True)
        arn = resp['certificateArn']
        public_key = resp['keyPair']['PublicKey']
        private_key = resp['keyPair']['PrivateKey']
        cert = resp['certificatePem']
    except Exception as e:
        print('error creating new certificate: %s' % e)
        return err_json('internal server error')

    # Attach credential
    try:
        client.attach_thing_principal(thingName=thing_name, principal=arn)
        client.attach_policy(policyName=('%s_edge' % config.DEPLOYMENT_NAME), target=arn)
    except Exception as e:
        print('error attaching new certificate: %s' % e)
        return err_json('internal server error')
    
    # Update database
    house.cert_arn = arn
    db.session.commit()

    # Revoke previous credential
    if len(cert_id) > 0:
        try:
            client.detach_thing_principal(thingName=thing_name, principal=cert_arn)
            client.detach_policy(policyName=('%s_edge' % config.DEPLOYMENT_NAME), target=cert_arn)
            client.update_certificate(certificateId=cert_id, newStatus='INACTIVE')
            client.delete_certificate(certificateId=cert_id)
        except Exception as e:
            print('error revoking certificate: %s' % e)
            return err_json('internal server error')

    return jsonify({
        'status': 'ok',
        'cert': cert,
        'private_key': private_key,
        'public_key': public_key
    })

@api_house.route('/sync', methods=['POST'])
@require_auth('admin')
def device_sync():
    data = request.json

    # Validate input
    if 'house_id' not in data:
        return err_json('bad request')
    house_id = int(data['house_id'])

    house = House.query.filter_by(house_id=house_id).first()
    if house is None:
        return err_json('house does not exist')

    # This is the data to be published
    data = []

    # Retrieve all devices
    devices = Device.query.filter_by(house_id=house_id).all()
    for device in devices:
        data.append({
            'device_id': device.device_id,
            'name': device.name,
            'type': device.type,
            'config': json.loads(device.config)
        })

    # Publish data as JSON string
    topic = '%s_config/%s_house_%d/devices' % (config.DEPLOYMENT_NAME, config.DEPLOYMENT_NAME, house_id)
    logger.info('Synchronizing house config, topic = %s' % topic)
    publish_str = json.dumps(data)
    publish(house_id, topic, publish_str)

    return jsonify({'status': 'ok'})