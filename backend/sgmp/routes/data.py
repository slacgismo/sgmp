from flask import Blueprint, jsonify

api_data = Blueprint('data', __name__)

@api_data.route('/read', methods=['POST'])
def data_read():
    return jsonify({
        'status': 'ok'
    })
