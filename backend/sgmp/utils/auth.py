from functools import wraps
from flask import json, request, g, jsonify
import cognitojwt

import utils.config as config

def decode_id_token(token):
    claim = cognitojwt.decode(token, config.AWS_REGION, config.COGNITO_USER_POOL_ID, testmode=(config.ENFORCE_AUTHENTICATION == '0'))
    user = {
        'roles': claim['cognito:groups'],
        'email': claim['email'],
        'name': claim['name']
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
                            print('Path %s requires roles %s, but the user only has roles %s' % (request.path, roles, user['roles']))
                except cognitojwt.exceptions.CognitoJWTException as e:
                    if config.ENFORCE_AUTHENTICATION != '0':
                        return jsonify({
                            'status': 'error',
                            'message': str(e)
                        }), 401
                    else:    
                        print('Path %s requires auth, but encountered during token check: %s' % (request.path, str(e)))
                except Exception as e:
                    if config.ENFORCE_AUTHENTICATION != '0':
                        return jsonify({
                            'status': 'error',
                            'message': 'invalid token'
                        }), 401
                    else:    
                        print('Path %s requires auth, but encountered during token check: %s' % (request.path, str(e)))
                return f(*args, **kwargs)
            
            if config.ENFORCE_AUTHENTICATION != '0':
                return jsonify({
                    'status': 'error',
                    'message': 'no token'
                }), 401

            print('Path %s requires auth, but no token is present' % request.path)
            return f(*args, **kwargs)
        return __require_auth
    return _require_auth