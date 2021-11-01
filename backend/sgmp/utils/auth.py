from functools import wraps
from flask import json, request, g, jsonify
import cognitojwt

from models.device import Device

from utils.logging import get_logger
import utils.config as config

logger = get_logger('auth')

def decode_id_token(token):
    claim = cognitojwt.decode(token, config.AWS_REGION, config.COGNITO_USER_POOL_ID, testmode=(config.ENFORCE_AUTHENTICATION == '0'))
    user = {
        'roles': claim['cognito:groups'],
        'email': claim['email'],
        'name': claim['name'],
        'house_id': int(claim['custom:home'])
    }
    return user

def user_has_role(user, allowed_roles):
    if allowed_roles is None: return True
    if isinstance(allowed_roles, str):
        allowed_roles = [allowed_roles]
    
    for role in user['roles']:
        if role in allowed_roles: return True

    return False

def require_auth(roles=None):
    def _require_auth(f):
        @wraps(f)
        def __require_auth(*args, **kwargs):
            auth_header = request.headers.get('Authorization')
            if auth_header:
                token = auth_header.split(' ')[1]
            else:
                token = ''
            if token:
                try:
                    user = decode_id_token(token)
                    g.user = user

                    if not user_has_role(user, roles):
                        if config.ENFORCE_AUTHENTICATION != '0':
                            return jsonify({
                                'status': 'error',
                                'message': 'insufficient privileges'
                            }), 403
                        else:
                            logger.warn('Path %s requires roles %s, but the user only has roles %s' % (request.path, roles, user['roles']))
                except cognitojwt.exceptions.CognitoJWTException as e:
                    if config.ENFORCE_AUTHENTICATION != '0':
                        return jsonify({
                            'status': 'error',
                            'message': str(e)
                        }), 401
                    else:    
                        logger.warn('Path %s requires auth, but encountered during token check: %s' % (request.path, str(e)))
                except Exception as e:
                    if config.ENFORCE_AUTHENTICATION != '0':
                        return jsonify({
                            'status': 'error',
                            'message': 'invalid token'
                        }), 401
                    else:    
                        logger.warn('Path %s requires auth, but encountered during token check: %s' % (request.path, str(e)))
                return f(*args, **kwargs)
            
            if config.ENFORCE_AUTHENTICATION != '0':
                return jsonify({
                    'status': 'error',
                    'message': 'no token'
                }), 401

            logger.warn('Path %s requires auth, but no token is present' % request.path)
            return f(*args, **kwargs)
        return __require_auth
    return _require_auth

def check_house_access():
    def _check_house_access(f):
        @wraps(f)
        def __check_house_access(*args, **kwargs):
            try:
                data = request.json
                requested_house_id = int(data['house_id'])
            except:
                return jsonify({
                    'status': 'error',
                    'message': 'bad request'
                }), 400

            if 'admin' in g.user['roles']:
                return f(*args, **kwargs)

            if requested_house_id == g.user['house_id']:
                return f(*args, **kwargs)
            
            logger.warn('User %s is assigned to house %d but tried to access house %d' % (g.user['email'], g.user['house_id'], requested_house_id))
            if config.ENFORCE_AUTHENTICATION == '0':
                return f(*args, **kwargs)

            return jsonify({
                'status': 'error',
                'message': 'access denied'
            }), 403
        return __check_house_access
    return _check_house_access

def check_house_or_device_access():
    def _check_house_or_device_access(f):
        @wraps(f)
        def __check_house_or_device_access(*args, **kwargs):
            try:
                data = request.json
            except:
                return jsonify({
                    'status': 'error',
                    'message': 'bad request'
                }), 400
            
            if 'admin' in g.user['roles']:
                return f(*args, **kwargs)

            requested_house_ids = []
            if 'house_id' in data:
                requested_house_ids = [int(data['house_id'])]
            elif 'device_id' in data:
                # Ensure user has access to all devices
                if isinstance(data['device_id'], int):
                    device_ids = [data['device_id']]
                elif isinstance(data['device_id'], str):
                    device_ids = [int(data['device_id'])]
                elif isinstance(data['device_id'], list):
                    device_ids = data['device_id']

                for device_id in device_ids:
                    device = Device.query.filter_by(device_id=device_id).first()
                    if device is None:
                        logger.warn('User %s attempts to access nonexist device %d' % (g.user['email'], device_id))
                        return jsonify({
                            'status': 'error',
                            'message': 'access denied'
                        }), 403
                    
                    requested_house_ids.append(device.house_id)

            # For each house, check if user has access
            check_ok = True
            for requested_house_id in requested_house_ids:
                if requested_house_id != g.user['house_id']:
                    check_ok = False
                    logger.warn('User %s is assigned to house %d but tried to access house %d' % (g.user['email'], g.user['house_id'], requested_house_id))

            if check_ok:
                return f(*args, **kwargs)

            if config.ENFORCE_AUTHENTICATION == '0':
                return f(*args, **kwargs)

            return jsonify({
                'status': 'error',
                'message': 'access denied'
            }), 403
        return __check_house_or_device_access
    return _check_house_or_device_access