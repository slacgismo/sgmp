from flask import Blueprint, jsonify, request
import json

from models.analytics import Analytics
from models.shared import db

from utils.functions import err_json
from utils.auth import require_auth

api_analytics = Blueprint('analytics', __name__)

@api_analytics.route('/list', methods=['GET'])
@require_auth()
def analytics_list():
    # Read all analytics from database
    query_result = Analytics.query.all()
    ret = []
    for row in query_result:
        ret.append({
            'analytics_id': row.analytics_id,
            'name': row.name,
            'description': row.description,
            'formula': row.formula
        })
    
    return jsonify({'status': 'ok', 'analytics': ret})

@api_analytics.route('/create', methods=['POST'])
@require_auth('admin')
def analytics_create():
    data = request.json

    # Validate input
    if 'name' not in data:
        return err_json('bad request')
    if 'description' not in data:
        return err_json('bad request')
    if 'formula' not in data:
        return err_json('bad request')

    # Check name does not exist
    count = Analytics.query.filter_by(name=data['name']).count()
    if count > 0:
        return err_json('analytics exists')

    # Save the data
    data = Analytics(
        name=data['name'],
        description=data['description'],
        formula=data['formula']
    )
    db.session.add(data)
    db.session.commit()

    return jsonify({'status': 'ok'})

@api_analytics.route('/update', methods=['POST'])
@require_auth('admin')
def analytics_update():
    data = request.json

    # Validate input
    if 'analytics_id' not in data:
        return err_json('bad request')
    if 'description' not in data:
        return err_json('bad request')
    if 'formula' not in data:
        return err_json('bad request')

    # Retrieve row
    row = Analytics.query.filter_by(analytics_id=int(data['analytics_id'])).first()
    if row is None:
        return err_json('analytics not found')

    # Save the data
    row.description = data['description']
    row.formula = data['formula']
    db.session.commit()

    return jsonify({'status': 'ok'})

@api_analytics.route('/delete', methods=['POST'])
@require_auth(['admin'])
def analytics_delete():
    data = request.json

    # Validate input
    if 'analytics_id' not in data:
        return err_json('bad request')
    analytics_id = int(data['analytics_id'])

    # Delete data from database
    Analytics.query.filter_by(analytics_id=analytics_id).delete()
    db.session.commit()

    return jsonify({'status': 'ok'})