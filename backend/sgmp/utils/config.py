import os

DATABASE_URL = os.environ.get('DATABASE_URL', 'sqlite:///test.sqlite')
DYNAMODB_TALBE = os.environ.get('DYNAMODB_TABLE', 'GismoLab_sgmp_device')
IOT_CLIENT_ID = os.environ.get('IOT_CLIENT_ID')
IOT_ENDPOINT = os.environ.get('IOT_ENDPOINT')
IOT_CERT_PATH = os.environ.get('IOT_CERT_PATH')
IOT_KEY_PATH = os.environ.get('IOT_KEY_PATH')
IOT_ROOT_PATH = os.environ.get('IOT_ROOT_PATH')