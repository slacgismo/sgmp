import os
import yaml

config = {}
try:
    with open('config.yaml', 'r') as f:
        config = yaml.load(f)
except:
    pass

def get_config(key, default=None):
    if key in config:
        return config[key]

    return os.environ.get(key, default)

DATABASE_URL = get_config('DATABASE_URL', 'sqlite:///test.sqlite')
DYNAMODB_TALBE = get_config('DYNAMODB_TABLE')
TSDB_HOST = get_config('TSDB_HOST')
TSDB_USER = get_config('TSDB_USER')
TSDB_PASS = get_config('TSDB_PASS')
TSDB_DATABASE = get_config('TSDB_DATABASE')
IOT_CLIENT_ID = get_config('IOT_CLIENT_ID')
IOT_ENDPOINT = get_config('IOT_ENDPOINT')
IOT_CERT_PATH = get_config('IOT_CERT_PATH')
IOT_KEY_PATH = get_config('IOT_KEY_PATH')
IOT_ROOT_PATH = get_config('IOT_ROOT_PATH')