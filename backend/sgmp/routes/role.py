from flask import Blueprint, jsonify

api_role = Blueprint('role', __name__)

@api_role.route('/list', methods=['GET'])
def role_list():
    # List the roles
    return jsonify({
        'status': 'ok'
    })

@api_role.route('/create', methods=['POST'])
def role_create():
    # Check that the role does not exist

    # Create the role
    return jsonify({
        'status': 'ok'
    })

@api_role.route('/delete', methods=['POST'])
def role_delete():
    # Delete the role
    return jsonify({
        'status': 'ok'
    })
