import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT

import utils.config as config

def publish(topic, data):
    # Initialize client
    mqtt = AWSIoTPyMQTT.AWSIoTMQTTClient(config.IOT_CLIENT_ID)
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