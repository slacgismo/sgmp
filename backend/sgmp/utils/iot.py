import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT
import urllib.request

from utils.logging import get_logger
from utils.functions import get_boto3_client

import utils.config as config

logger = get_logger('iot')

iot_cert_path = config.IOT_CERT_PATH
iot_root_path = config.IOT_ROOT_PATH

def initialize():
    global iot_cert_path
    global iot_root_path

    logger.info('Initializing AWS IoT Core credentials')
    # Read certificate
    if iot_cert_path is None:
        logger.info('Reading certificate %s' % config.IOT_CERT_ID)
        client = get_boto3_client('iot')
        resp = client.describe_certificate(certificateId=config.IOT_CERT_ID)
        pem_content = resp['certificateDescription']['certificatePem']
        pem_path = '/tmp/iot_cert.pem'
        logger.info('Writing certificate to %s' % pem_path)
        with open(pem_path, 'w') as f:
            f.write(pem_content)
        iot_cert_path = pem_path

    # Default to AmazonRootCA1.pem
    if iot_root_path is None:
        logger.info('Attempting to retrieve default CA certificate AmazonRootCA1')
        iot_root_path = '/tmp/AmazonRootCA1.pem'
        url = 'https://www.amazontrust.com/repository/AmazonRootCA1.pem'
        with urllib.request.urlopen(url) as response, open(iot_root_path, 'wb') as out_file:
            data = response.read()
            out_file.write(data)

    logger.info('Making a test connection')
    mqtt = mqtt_connect()
    mqtt.disconnect()
    logger.info('IoT Core initialize completed')

def mqtt_connect():
    global iot_cert_path
    global iot_root_path

    # Initialize client
    client_id = config.DEPLOYMENT_NAME + '_backend'
    logger.info('Connecting to endpoint %s, client ID %s' % (config.IOT_ENDPOINT, client_id))
    mqtt = AWSIoTPyMQTT.AWSIoTMQTTClient(client_id)
    mqtt.configureEndpoint(config.IOT_ENDPOINT, 8883)
    mqtt.configureCredentials(iot_root_path, config.IOT_KEY_PATH, iot_cert_path)
    mqtt_connect = False

    # Connect to MQTT
    retries = 5
    for i in range(retries):
        mqtt_connect = mqtt.connect()
        if mqtt_connect: break

    if not mqtt_connect:
        raise Exception('could not connect to MQTT!')

    return mqtt

def publish(house_id, topic, data):
    mqtt = mqtt_connect()

    # Publish to topic
    mqtt.publish(topic, data, QoS=1)
    mqtt.disconnect()