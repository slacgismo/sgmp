from flask import Blueprint, jsonify, request
from flask.globals import current_app
import boto3
import datetime
import random
import string


api_user = Blueprint('user', __name__)
client = boto3.client('cognito-idp', region_name='us-west-1')
user_pool_id = 'us-west-1_opTsFEaul'
app_client_id = '225gul2k0qlq0vjh81cd3va4h'


#### helper function ########
# generate a 16 digit random password
def random_password_generator ():
    lower = string.ascii_lowercase
    upper = string.ascii_uppercase
    num = string.digits
    symbol = string.punctuation
    password = "Aa!9"
    all = lower + upper + num + symbol

    temp = random.sample(all, 8)
    password += ("".join(temp))

    return password

def search_role_for_user (email):
    response = client.admin_list_groups_for_user(
        Username=email,
        UserPoolId=user_pool_id,
    )

    groups = []
    for group in response['Groups']:
        groups.append(group['GroupName'])

    return groups

def get_user_email_from_accessToken (accesstoken):
    response = ""
    try:
        response = client.get_user(
            AccessToken=accesstoken
        )
    except Exception as e:
        return e

    return response['Username']

def get_user_information_from_email (email):
    response = ""
    try:
        response = client.admin_get_user(
            UserPoolId=user_pool_id,
            Username=email
        )
    except Exception as e:
        return e
    user_info = {}
    user_info['create_date'] = response['UserCreateDate']
    for attribute in response['UserAttributes']:
        attribute_name = attribute['Name']
        attribute_value = attribute['Value']
        user_info[attribute_name] = attribute_value
    return user_info


def update_user_attribute (email, name):
    response = ""

    try:
        response = client.admin_update_user_attributes(
            UserPoolId=user_pool_id,
            Username=email,
            UserAttributes=[
                {
                    'Name': 'name',
                    'Value': name
                },
            ]
        )
    except Exception as e:
        return e
    return 'ok'

def remove_user_from_role (email, role):
    response = ""
    try:
        response = client.admin_remove_user_from_group(
            UserPoolId=user_pool_id,
            Username=email,
            GroupName=role
        )
    except Exception as e:
        return e
    return 'ok'

def add_user_into_role (email, role):
    response = ""
    try:
        response = client.admin_add_user_to_group(
            UserPoolId=user_pool_id,
            Username=email,
            GroupName=role
        )
    except Exception as e:
        return e
    return 'ok'

##############################

#list the users
@api_user.route('/list', methods=['GET'])
def user_list():
    us_pool_id = user_pool_id
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
def user_create():
    status = 'ok'
    email = request.form.get("email")
    name = request.form.get("name")
    try:
        response = client.admin_create_user(
            UserPoolId=user_pool_id,
            Username=email,
            UserAttributes=[
                {
                    'Name': 'name',
                    'Value': name
                },
            ],
            TemporaryPassword=random_password_generator(),
            DesiredDeliveryMediums=[
                'EMAIL'
            ]
        )
    except Exception as e:
        status = e

    return jsonify({
        'status': status
    })

# user authentication
@api_user.route('/login', methods=['POST']) 
def user_login():
    # validate the user's identification and return a access token
    email = request.form.get("email")
    password = request.form.get("password")
    status = 'ok'
    response = ""
    access_token = ""
    try:
        response = client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': email,
                'PASSWORD': password
            },
            ClientId=app_client_id,
        )
        access_token = ""
        # get access token
        if 'AuthenticationResult' in response:
            access_token = response['AuthenticationResult']['AccessToken']
    except Exception:
        status = 'incorrect password/email'
    
    return jsonify({
        'status': status,
        'accesstoken': access_token
    })

# change the user's password
@api_user.route('/changePassword', methods=['POST'])
def user_change_password():
    email = request.form.get("email")
    new_password = request.form.get("password")
    response = client.admin_set_user_password(
        UserPoolId=user_pool_id,
        Username=email,
        Password=new_password,
        Permanent=True
    )

    return jsonify({
        'status': 'ok'
    })

# update user's profile 
@api_user.route('/update', methods=['POST'])
def user_update():
    # Check the user exists
    status = "ok"
    user_info = {}
    email = request.form.get("email")
    name = request.form.get("name")
    role = request.form.get("role")

    # update name
    if update_user_attribute(email, name) != 'ok':
        status = 'error in updating name'
    # update role
    current_role = search_role_for_user(email)
    if len(current_role) == 0:
        if add_user_into_role(email, role) != 'ok':
            status = 'error in adding role'
    elif current_role[0] != role:
        if remove_user_from_role(email, current_role[0]) != 'ok':
            status = 'error in removing role'
        if add_user_into_role(email, role) != 'ok':
            status = 'error in adding role'

    # Update the user
    return jsonify({
        'status': 'ok'
    })

# delete user
@api_user.route('/delete', methods=['POST'])
def user_delete():
    # Delete the user
    email = request.form.get("email")
    response = ""
    status = "ok"
    try:
        response = client.admin_delete_user(
            UserPoolId=user_pool_id,
            Username=email
        )
    except Exception:
        status = "error"

    return jsonify({
        'status': status
    })