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

IOT_ENDPOINT = get_config('IOT_ENDPOINT')
IOT_CLIENT_ID = get_config('IOT_CLIENT_ID')
IOT_CERT_PATH = get_config('IOT_CERT_PATH')
IOT_KEY_PATH = get_config('IOT_KEY_PATH')
IOT_ROOT_PATH = get_config('IOT_ROOT_PATH')
TOPIC_CONTROL_SONNEN = get_config('TOPIC_CONTROL_SONNEN')