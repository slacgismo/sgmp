from flask import Blueprint, jsonify
from flask.globals import request

from utils.functions import get_boto3_client, err_json
from utils.auth import require_auth
import utils.config as config

api_role = Blueprint('role', __name__)

###### Helper function ##########
# list user in the group
def list_user_in_group(group_name):
    user_list = []
    client = get_boto3_client('cognito-idp')
    response = client.list_users_in_group(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        GroupName=group_name,
    )
    for user in response['Users']:
        user_list.append(user['Username'])
    
    return user_list

def delete_group(group_name):
    try:
        client = get_boto3_client('cognito-idp')
        response = client.delete_group(
            GroupName=group_name,
            UserPoolId=config.COGNITO_USER_POOL_ID
        )
    except Exception:
        return None
################################

# list all of roles
@api_role.route('/list', methods=['GET'])
@require_auth('admin')
def role_list():
    # List the roles
    role_list = []
    client = get_boto3_client('cognito-idp')
    response = client.list_groups(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        Limit=20
    )
    for group in response['Groups']:
        role_list.append(group['GroupName'])

    return jsonify({
        'status': 'ok',
        'role_list': role_list,
    })

# create a role
@api_role.route('/create', methods=['POST'])
@require_auth('admin')
def role_create():
    group_name = request.json.get('role')
    if group_name is None:
        return err_json('invalid request')
    # Check that the role does not exist
    client = get_boto3_client('cognito-idp')
    client.create_group(
        GroupName=group_name,
        UserPoolId=config.COGNITO_USER_POOL_ID,
    )
    # Create the role
    return jsonify({
        'status': 'ok'
    })

# delete a group
@api_role.route('/delete', methods=['POST'])
@require_auth('admin')
def role_delete():
    group_name = request.json.get('role')
    if group_name is None:
        return err_json('invalid request')
    list_user = list_user_in_group(group_name)

    if list_user is None:
        return err_json('error in listing user')
    elif len(list_user) != 0:
        return err_json('some users still in list')
    else:
        if delete_group(group_name) is None:
            return err_json('error in deleting group')

    return jsonify({
        'status': 'ok'
    })
