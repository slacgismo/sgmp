from flask import jsonify

def err_json(message):
    return jsonify({'status': 'error', 'message': message})