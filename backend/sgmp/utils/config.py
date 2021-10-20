import os
import yaml

config = {}
try:
    with open('config.yaml', 'r') as f:
        config = yaml.load(f, Loader=yaml.SafeLoader)
except:
    pass

def get_config(key, default=None):
    if key in os.environ:
        return os.environ.get(key)
    if key in config:
        return str(config[key])

    return default

DATABASE_URL = get_config('DATABASE_URL', 'sqlite:///test.sqlite')
TSDB_HOST = get_config('TSDB_HOST')
TSDB_USER = get_config('TSDB_USER')
TSDB_PASS = get_config('TSDB_PASS')
TSDB_DATABASE = get_config('TSDB_DATABASE')
IOT_CERT_ID = get_config('IOT_CERT_ID')
IOT_CLIENT_ID = get_config('IOT_CLIENT_ID')
IOT_ENDPOINT = get_config('IOT_ENDPOINT')
IOT_CERT_PATH = get_config('IOT_CERT_PATH')
IOT_KEY_PATH = get_config('IOT_KEY_PATH')
IOT_ROOT_PATH = get_config('IOT_ROOT_PATH')
AWS_REGION = get_config('AWS_REGION')
COGNITO_USER_POOL_ID = get_config('COGNITO_USER_POOL_ID')
COGNITO_APP_CLIENT_ID = get_config('COGNITO_APP_CLIENT_ID')
ENFORCE_AUTHENTICATION = get_config('ENFORCE_AUTHENTICATION', '1')