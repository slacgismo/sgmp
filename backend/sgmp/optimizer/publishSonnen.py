import config
import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT
import json

# Pubsub Config
IOT_ENDPOINT = config.IOT_ENDPOINT
IOT_CLIENT_ID = config.IOT_CLIENT_ID
IOT_CERT_PATH = config.IOT_CERT_PATH
IOT_KEY_PATH = config.IOT_KEY_PATH
IOT_ROOT_PATH = config.IOT_ROOT_PATH
TOPIC_CONTROL_SONNEN = config.TOPIC_CONTROL_SONNEN

# Publish output of the optimizer algorithm to an MQTT control topic for specific house
def publishPowerValues(publishMessage):
    # initialize client:
    myAWSIoTMQTTClient = AWSIoTPyMQTT.AWSIoTMQTTClient(IOT_CLIENT_ID)
    myAWSIoTMQTTClient.configureEndpoint(IOT_ENDPOINT, 8883)
    myAWSIoTMQTTClient.configureCredentials(IOT_ROOT_PATH, IOT_KEY_PATH, IOT_CERT_PATH)
    
    mqtt_connect = False
    while not(mqtt_connect):
        mqtt_connect = myAWSIoTMQTTClient.connect()
        print("Connected to AWS IoT client: ", mqtt_connect)

    myAWSIoTMQTTClient.publish(TOPIC_CONTROL_SONNEN + publishMessage["DeviceID"], json.dumps(publishMessage), QoS=1)