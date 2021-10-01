from flask import jsonify
import json
import decimal

def err_json(message):
    return jsonify({'status': 'error', 'message': message})