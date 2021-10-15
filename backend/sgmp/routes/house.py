from flask import Blueprint, jsonify, request

from models.house import House
from models.device import Device
from models.shared import db

from utils.functions import err_json
from utils.auth import require_auth

api_house = Blueprint('house', __name__)

@api_house.route('/list', methods=['GET'])
@require_auth()
def house_list():
    # Read all house from database
    query_result = House.query.all()
    ret = []
    for row in query_result:
        ret.append({
            'house_id': row.house_id,
            'name': row.name,
            'description': row.description
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
        description=data['description']
    )
    db.session.add(data)
    db.session.commit()

    return jsonify({'status': 'ok'})

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

    # Save the data
    if 'name' in data:
        count = House.query.filter_by(name=data['name']).count()
        if count > 0:
            return err_json('new house name exists')
        row.name = data['name']
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

    # Delete data from database
    House.query.filter_by(house_id=house_id).delete()
    db.session.commit()

    return jsonify({'status': 'ok'})