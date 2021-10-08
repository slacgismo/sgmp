import string
from flask import Blueprint, jsonify
from flask.globals import request
import boto3

user_pool_id = 'us-west-1_opTsFEaul'
api_role = Blueprint('role', __name__)
client = boto3.client('cognito-idp')

###### Helper function ##########
# list user in the group
def list_user_in_group (group_name):
    response = ""
    user_list = []
    try:
        response = client.list_users_in_group(
            UserPoolId=user_pool_id,
            GroupName=group_name,
        )
        for user in response['Users']:
            user_list.append(user['Username'])
    except Exception:
        return None
    
    return user_list

def delete_group(group_name) :
    try:
        response = client.delete_group(
            GroupName=group_name,
            UserPoolId=user_pool_id
        )
    except Exception:
        return None
################################

# list all of roles
@api_role.route('/list', methods=['GET'])
def role_list():
    # List the roles
    role_list = []
    try:
        response = client.list_groups(
            UserPoolId=user_pool_id,
            Limit=20
        )
        for group in response['Groups']:
            role_list.append(group['GroupName'])
    except Exception as e:
        status = e

    return jsonify({
        'status': 'ok',
        'role_list': role_list,
    })

# create a role
@api_role.route('/create', methods=['POST'])
def role_create():
    group_name = request.form.get("role")
    # Check that the role does not exist
    status = "ok"
    response = ""
    try:
        response = client.create_group(
            GroupName=group_name,
            UserPoolId=user_pool_id,
        )
    except Exception as e:
        status = e
    # Create the role
    return jsonify({
        'status': status
    })

# delete a group
@api_role.route('/delete', methods=['POST'])
def role_delete():
    group_name = request.form.get("role")
    response = ""
    status = "ok"
    list_user = list_user_in_group(group_name)

    if list_user is None:
        status = "error in listing user"
    elif len(list_user) != 0:
        status = "some users still in list"
    else:
        if delete_group(group_name) is None:
            status = "error in deleting group"
        status = "ok"

    return jsonify({
        'status': status
    })
