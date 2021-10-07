from flask import Blueprint, jsonify, request
import boto3
import datetime
import random
import string


api_user = Blueprint('user', __name__)
client = boto3.client('cognito-idp')

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
        UserPoolId='us-west-1_opTsFEaul',
    )

    groups = []
    for group in response['Groups']:
        groups.append(group['GroupName'])

    return groups
##############################

#list the users
@api_user.route('/list', methods=['GET'])
def user_list():
    us_pool_id = 'us-west-1_opTsFEaul'
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
        'response_list_users': response_list_users

    })

# user creation
@api_user.route('/create', methods=['POST'])
def user_create():
    status = 'ok'
    email = request.form.get("email")
    name = request.form.get("name")
    user_pool_id = 'us-west-1_opTsFEaul'
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
        print(e)
        status = 'error'

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
            ClientId='225gul2k0qlq0vjh81cd3va4h',
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

@api_user.route('/changePassword', methods=['POST'])
def user_change_password():
    email = request.form.get("email")
    new_password = request.form.get("password")
    response = client.admin_set_user_password(
        UserPoolId='us-west-1_opTsFEaul',
        Username=email,
        Password=new_password,
        Permanent=True
    )

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