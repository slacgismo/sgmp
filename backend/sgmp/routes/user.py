from os import stat
from flask import Blueprint, jsonify, request, g
import random
import string

from werkzeug.utils import validate_arguments
from models.house import House

from flask.wrappers import Response

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
    password = 'Aa!9'
    all = lower + upper + num

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
    try:
        response = client.admin_get_user(
            UserPoolId=config.COGNITO_USER_POOL_ID,
            Username=email
        )
    except Exception as e:
        return 'error'
    user_info = {}
    user_info['create_date'] = response['UserCreateDate']
    for attribute in response['UserAttributes']:
        attribute_name = attribute['Name']
        attribute_value = attribute['Value']
        user_info[attribute_name] = attribute_value
    if 'custom:home' not in user_info:
        user_info['custom:home'] = ''
    return user_info


def update_user_attribute(email, name, house_id):
    client = get_boto3_client('cognito-idp')
    client.admin_update_user_attributes(
        UserPoolId=config.COGNITO_USER_POOL_ID,
        Username=email,
        UserAttributes=[
            {
                'Name': 'name',
                'Value': name
            },
            {
                'Name': 'custom:home',
                'Value': str(house_id)
            }
        ]
    )
    return 'ok'

def remove_user_from_role(email, role):
    client = get_boto3_client('cognito-idp')
    try:
        client.admin_remove_user_from_group(
            UserPoolId=config.COGNITO_USER_POOL_ID,
            Username=email,
            GroupName=role
        )
    except Exception as e:
        return 'error'
    return 'ok'

def add_user_into_role(email, role):
    client = get_boto3_client('cognito-idp')
    try:
        client.admin_add_user_to_group(
            UserPoolId=config.COGNITO_USER_POOL_ID,
            Username=email,
            GroupName=role
        )
    except Exception as e:
        return 'error'
    return 'ok'

def house_validate(house_id):

    # validate if the house id exit
    count = House.query.filter_by(house_id=house_id).count()
    if count == 0:
        return 'house not exit'
    return 'ok'

def get_token (request):
    auth_header = request.headers.get('Authorization')
    return auth_header.split(' ')[1]

def get_house_description (house_id):
    return House.query.filter_by(house_id=house_id).first().description


##############################

# return the profile of currently logged in user
@api_user.route('/profile', methods=['GET'])
@require_auth()
def user_profile():
    return jsonify({
        'status': 'ok',
        'profile': g.user
    })

# return the user information
@api_user.route('/information', methods=['POST'])
@require_auth("admin")
def user_information():
    email = request.json.get("email")
    user_information = get_user_information_from_email(email)
    if user_information == 'error':
        return err_json("error in reading user information")
    user_groups = search_role_for_user(email)
    if user_groups == 'error' or user_groups is None:
        return err_json("error in reading user group")
    
    print(user_information)
    house_id = user_information['custom:home']
    house_description = get_house_description(house_id)
    name = user_information['name']
    create_date = user_information['create_date']
    return jsonify({
        "status": 'ok',
        "group": user_groups[0],
        "house_id": int(user_information['custom:home']),
        "house_description": house_description,
        "create_date": create_date,
        "name": name
    })

#list the users
@api_user.route('/list', methods=['GET'])
@require_auth('admin')
def user_list():
    client = get_boto3_client('cognito-idp')
    us_pool_id = config.COGNITO_USER_POOL_ID
    users = []
    user_list = []
    pagination_token = ''
    response_list_users = client.list_users(
        UserPoolId=us_pool_id,
        Limit=30,
    )
    users += response_list_users['Users']
    if 'PaginationToken' in response_list_users: 
        pagination_token = response_list_users['PaginationToken']
    while pagination_token != '':
        response_list_users = client.list_users(
            UserPoolId=us_pool_id,
            Limit=30,
            PaginationToken = pagination_token
        )
        users += response_list_users['Users']

    for user_entry in users:
        user_list_entry = {}
        user_list_entry['create_time'] = user_entry['UserCreateDate']
        for attribute in user_entry['Attributes']:
            if attribute['Name'] == 'email':
                user_list_entry['email'] = attribute['Value']
            if attribute['Name'] == 'name':
                user_list_entry['name'] = attribute['Value']
            if attribute['Name'] == 'custom:home':
                user_list_entry['house_id'] = int(attribute['Value'])
                user_list_entry['house_description'] = get_house_description(attribute['Value'])
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
    house = request.json.get('house_id')
    role = request.json.get('role')
    password = random_password_generator()

    # validte if the input invalidate
    if email is None or name is None or house is None or role is None:
        return err_json('invalid request')
    # validate if the home id exist
    if house_validate(house) != 'ok':
        return err_json('invalid house id')
    try:
        client.admin_create_user(
            UserPoolId=config.COGNITO_USER_POOL_ID,
            Username=email,
            UserAttributes=[
                {
                    'Name': 'name',
                    'Value': name
                },
                {
                    'Name': 'custom:home',
                    'Value': house
                }
            ],
            TemporaryPassword=password,
            DesiredDeliveryMediums=[
                'EMAIL'
            ]
        )
        client.admin_set_user_password(
            UserPoolId=config.COGNITO_USER_POOL_ID,
            Username=email,
            Password=password,
            Permanent=True
        )
        if add_user_into_role(email, role) != 'ok':
            return err_json('error in adding user')
    except Exception as e:
        return err_json("error in creating user")

    return jsonify({
        'status': 'ok'
    })

# user password update
@api_user.route('/updatePassword', methods = ['POST'])
@require_auth()
def user_updatePassword():
    client = get_boto3_client('cognito-idp')
    old_password = request.json.get("old_password")
    new_password = request.json.get("new_password")
    id_token = get_token(request)
    email = decode_id_token(id_token)['email']
    response = client.initiate_auth(
        AuthFlow='USER_PASSWORD_AUTH',
        AuthParameters={
            'USERNAME': email,
            'PASSWORD': old_password
        },
        ClientId=config.COGNITO_APP_CLIENT_ID,
    )
    access_token = ''
    # get access token
    if 'AuthenticationResult' in response:
        access_token = response['AuthenticationResult']['AccessToken']
    else:
        return err_json('failed to login')
    
    try:
        client.change_password(
            PreviousPassword=old_password,
            ProposedPassword=new_password,
            AccessToken=str(access_token)
        )
    except Exception as e:
        return err_json('error in updating password')
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
    response = ''
    house_id = ''
    house_description = ''
    refresh_token = ''
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
            refresh_token = response['AuthenticationResult']['RefreshToken']
        else:
            return err_json('failed to login')
        
        # get user's house_id and house description
        response = get_user_information_from_email(email)
        if 'custom:home' in response:
            house_id = response['custom:home']
            house_description = get_house_description(house_id)

    except Exception as e:
        return err_json('error in logging in the account')

    profile = decode_id_token(access_token)

    return jsonify({
        'status': 'ok',
        'accesstoken': access_token,
        'profile': profile,
        'house_id': int(house_id),
        'house_description': house_description,
        'refresh_token': refresh_token
    })

# refresh the token
@api_user.route('/refreshToken', methods=['POST'])
def user_refresh_token ():
    refresh_token = request.json.get('refresh_token')
    if refresh_token is None:
        return err_json('failed to refresh (no valid token')
    try:
        client = get_boto3_client('cognito-idp')
        response = client.initiate_auth(
            AuthFlow='REFRESH_TOKEN',
            AuthParameters={
                'REFRESH_TOKEN': refresh_token
            },
            ClientId=config.COGNITO_APP_CLIENT_ID,
        )
        if 'AuthenticationResult' in response:
            access_token = response['AuthenticationResult']['IdToken']
        else:
            return err_json('failed to refresh')
    except Exception as e:
        return err_json("error in refreshing token")
    print("here!")
    return jsonify({
        'status': 'ok',
        'accesstoken': access_token
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
    try:
        client.admin_set_user_password(
            UserPoolId=config.COGNITO_USER_POOL_ID,
            Username=email,
            Password=new_password,
            Permanent=True
        )
    except Exception as e:
        return err_json("error in changing password")

    return jsonify({
        'status': 'ok'
    })

# update user's profile 
@api_user.route('/update', methods=['POST'])
@require_auth('admin')
def user_update():
    # Check the input
    email = request.json.get('email')
    name = request.json.get('name')
    role = request.json.get('role')
    house_id = request.json.get('house_id')
    if email is None or name is None or role is None:
        return err_json('invalid request')
    if house_validate(house_id) != 'ok':
        return err_json('invalid house id')
    # update user
    if update_user_attribute(email, name, house_id) != 'ok':
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

    house_description = get_house_description(house_id)

    return jsonify({
        'email': email,
        'name': name,
        'role': role,
        "house_id": int(house_id),
        "house_description": house_description,
        'status': 'ok'
    })

# delete user
@api_user.route('/delete', methods=['POST'])
@require_auth('admin')
def user_delete():
    # Delete the user
    email_list = request.json.get('user_list')
    if email_list is None or len(email_list) == 0:
        return err_json('invalid request')
    client = get_boto3_client('cognito-idp')
    try:
        for email in email_list:
            client.admin_delete_user(
                UserPoolId=config.COGNITO_USER_POOL_ID,
                Username=email
            )
    except Exception as e:
        return err_json('error in deleting user account')

    return jsonify({
        'status': 'ok'
    })
