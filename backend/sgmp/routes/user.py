from flask import Blueprint, jsonify, request, g
import random
import string

import utils.config as config
from utils.functions import get_boto3_client, err_json
from utils.auth import require_auth, decode_id_token

api_user = Blueprint('user', __name__)

#### helper function ########
# generate a 16 digit random password
def random_password_generator():
    lower = string.ascii_lowercase
    upper = string.ascii_uppercase
    num = string.digits
    symbol = string.punctuation
    password = 'Aa!9'
    all = lower + upper + num + symbol

    temp = random.sample(all, 8)
    password += (''.join(temp))

    return password

def search_role_for_user(email):
    client = get_boto3_client('cognito-idp')
    response = client.admin_list_groups_for_user(
        Username=email,
        UserPoolId=config.COGNITO_USER_POOL_ID,
    )

    groups = []
    for group in response['Groups']:
        groups.append(group['GroupName'])

    return groups

def get_user_information_from_email(email):
    client = get_boto3_client('cognito-idp')
    response = client.admin_get_user(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        Username=email
    )
    user_info = {}
    user_info['create_date'] = response['UserCreateDate']
    for attribute in response['UserAttributes']:
        attribute_name = attribute['Name']
        attribute_value = attribute['Value']
        user_info[attribute_name] = attribute_value
    return user_info


def update_user_attribute(email, name):
    client = get_boto3_client('cognito-idp')
    client.admin_update_user_attributes(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        Username=email,
        UserAttributes=[
            {
                'Name': 'name',
                'Value': name
            },
        ]
    )
    return 'ok'

def remove_user_from_role(email, role):
    client = get_boto3_client('cognito-idp')
    client.admin_remove_user_from_group(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        Username=email,
        GroupName=role
    )
    return 'ok'

def add_user_into_role(email, role):
    client = get_boto3_client('cognito-idp')
    client.admin_add_user_to_group(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        Username=email,
        GroupName=role
    )
    return 'ok'

##############################

# return the profile of currently logged in user
@api_user.route('/profile', methods=['GET'])
@require_auth()
def user_profile():
    return jsonify({
        'status': 'ok',
        'profile': g.user
    })

#list the users
@api_user.route('/list', methods=['GET'])
@require_auth('admin')
def user_list():
    client = get_boto3_client('cognito-idp')
    us_pool_id = config.COGNITO_USER_POOL_ID
    response_list_users = client.list_users(
        UserPoolId=us_pool_id,
        Limit=30,
    )

    user_list = []

    for user_entry in response_list_users['Users']:
        user_list_entry = {}
        user_list_entry['create_time'] = user_entry['UserCreateDate']
        for attribute in user_entry['Attributes']:
            if attribute['Name'] == 'email':
                user_list_entry['email'] = attribute['Value']
            if attribute['Name'] == 'name':
                user_list_entry['name'] = attribute['Value']

        user_list_entry['role'] = search_role_for_user(user_list_entry['email'])
        
        user_list.append(user_list_entry)
    return jsonify({
        'status': 'ok',
        'user_list': user_list,
    })

# user creation
@api_user.route('/create', methods=['POST'])
@require_auth('admin')
def user_create():
    client = get_boto3_client('cognito-idp')
    email = request.json.get('email')
    name = request.json.get('name')
    password = random_password_generator()
    if email is None or name is None:
        return err_json('invalid request')
    try:
        client.admin_create_user(
            UserPoolId=config.COGNITO_USER_POOL_ID,
            Username=email,
            UserAttributes=[
                {
                    'Name': 'name',
                    'Value': name
                },
            ],
            TemporaryPassword=password,
            DesiredDeliveryMediums=[
                'EMAIL'
            ]
        )
        response = client.admin_set_user_password(
            UserPoolId=config.COGNITO_USER_POOL_ID,
            Username=email,
            Password=password,
            Permanent=True
        )
    except Exception as e:
        status = str(e)

    return jsonify({
        'status': 'ok'
    })

# user authentication
@api_user.route('/login', methods=['POST'])
def user_login():
    # validate the user's identification and return a access token
    email = request.json.get('email')
    password = request.json.get('password')
    if email is None or password is None:
        return err_json('invalid request')
    access_token = ''
    try:
        client = get_boto3_client('cognito-idp')
        response = client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': email,
                'PASSWORD': password
            },
            ClientId=config.COGNITO_APP_CLIENT_ID,
        )
        access_token = ''
        # get access token
        if 'AuthenticationResult' in response:
            access_token = response['AuthenticationResult']['IdToken']
        else:
            return err_json('failed to login')
    except Exception:
        return err_json('email or password incorrect')
    
    profile = decode_id_token(access_token)

    return jsonify({
        'status': 'ok',
        'accesstoken': access_token,
        'profile': profile
    })

# change the user's password
@api_user.route('/changePassword', methods=['POST'])
@require_auth('admin')
def user_change_password():
    email = request.json.get('email')
    new_password = request.json.get('password')
    if email is None or new_password is None:
        return err_json('invalid request')
    client = get_boto3_client('cognito-idp')
    client.admin_set_user_password(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        Username=email,
        Password=new_password,
        Permanent=True
    )

    return jsonify({
        'status': 'ok'
    })

# update user's profile 
@api_user.route('/update', methods=['POST'])
@require_auth('admin')
def user_update():
    # Check the user exists
    email = request.json.get('email')
    name = request.json.get('name')
    role = request.json.get('role')
    if email is None or name is None or role is None:
        return err_json('invalid request')

    # update name
    if update_user_attribute(email, name) != 'ok':
        return err_json('error in updating name')
    # update role
    current_role = search_role_for_user(email)
    if len(current_role) == 0:
        if add_user_into_role(email, role) != 'ok':
            return err_json('error in adding role')
    elif current_role[0] != role:
        if remove_user_from_role(email, current_role[0]) != 'ok':
            return err_json('error in removing role')
        if add_user_into_role(email, role) != 'ok':
            return err_json('error in adding role')

    # Update the user
    return jsonify({
        'status': 'ok'
    })

# delete user
@api_user.route('/delete', methods=['POST'])
@require_auth('admin')
def user_delete():
    # Delete the user
    email = request.json.get('email')
    if email is None:
        return err_json('invalid request')
    client = get_boto3_client('cognito-idp')
    client.admin_delete_user(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        Username=email
    )

    return jsonify({
        'status': 'ok'
    })