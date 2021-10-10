from flask import jsonify
import boto3

import utils.config as config

def err_json(message):
    return jsonify({'status': 'error', 'message': message})

def get_obj_path(obj, path):
    if path in obj:
        return obj[path]
    
    path = path.split('.')
    cursor = obj
    for component in path:
        if isinstance(cursor, list):
            component = int(component)
            if component >= len(cursor):
                return None
            cursor = cursor[component]
            continue
        
        if component not in cursor:
            return None
        cursor = cursor[component]

    if isinstance(cursor, str):
        cursor = float(cursor)

    return cursor

def get_boto3_client(service):
    client = boto3.client(service, region_name=config.AWS_REGION)
    return client