from flask import Blueprint, jsonify

api_user = Blueprint('user', __name__)

@api_user.route('/list', methods=['GET'])
def user_list():
    # List the users
    return jsonify({
        'status': 'ok'
    })

@api_user.route('/create', methods=['POST'])
def user_create():
    # Check the email does not exist

    # Check the role exists

    # Create the user
    return jsonify({
        'status': 'ok'
    })

@api_user.route('/update', methods=['POST'])
def user_update():
    # Check the user exists

    # Update the user
    return jsonify({
        'status': 'ok'
    })

@api_user.route('/delete', methods=['POST'])
def user_delete():
    # Delete the user
    return jsonify({
        'status': 'ok'
    })