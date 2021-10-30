import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT

from utils.logging import get_logger

import utils.config as config

logger = get_logger('iot')

def publish(house_id, topic, data):
    # Initialize client
    client_id = config.DEPLOYMENT_NAME + '_backend'
    logger.info('Connecting to endpoint %s, client ID %s' % (config.IOT_ENDPOINT, client_id))
    mqtt = AWSIoTPyMQTT.AWSIoTMQTTClient(client_id)
    mqtt.configureEndpoint(config.IOT_ENDPOINT, 8883)
    mqtt.configureCredentials(config.IOT_ROOT_PATH, config.IOT_KEY_PATH, config.IOT_CERT_PATH)
    mqtt_connect = False

    # Connect to MQTT
    retries = 5
    for i in range(retries):
        mqtt_connect = mqtt.connect()
        if mqtt_connect: break

    if not mqtt_connect:
        raise Exception('could not connect to MQTT!')

    # Publish to topic
    mqtt.publish(topic, data, QoS=1)
    mqtt.disconnect()