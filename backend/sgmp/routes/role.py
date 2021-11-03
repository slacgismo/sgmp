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
    next_token = ''
    groups = []
    response = client.list_users_in_group(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        GroupName=group_name
    )
    groups += response['Users']

    # paginate through the list
    if 'NextToken' in response:
        next_token = response['NextToken']
    while next_token != '':
        response = client.list_users_in_group(
            UserPoolId=config.COGNITO_USER_POOL_ID,
            GroupName=group_name,
            NextToken = next_token
        )
        groups += response['Users']
        if 'NextToken' in response:
            next_token = response['NextToken']
        else:
            next_token = ''

    # take email out from the list
    user_list = []
    for user in groups:
        for attribute in user['Attributes']:
            if attribute['Name'] == 'email':
                user_list.append(attribute['Value'])
    return user_list

def delete_group(group_name):
    try:
        client = get_boto3_client('cognito-idp')
        client.delete_group(
            GroupName=group_name,
            UserPoolId=config.COGNITO_USER_POOL_ID
        )
    except Exception:
        return None
    return 'ok'
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

    # put assigned users into role
    user_list_for_role = {}
    for role in role_list:
        user_list_for_role[role] = list_user_in_group(role)
    user_list_for_role['status'] = 'ok'

    return jsonify(user_list_for_role)

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
