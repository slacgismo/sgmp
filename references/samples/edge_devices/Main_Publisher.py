'''This function will be running on the RPi'''

import pubsubClass
import config
import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT
import egauge_local_api
import sonnen_local_api

CLIENT_ID = config.CLIENT_ID
ENDPOINT = config.ENDPOINT
PATH_TO_CERT = config.PATH_TO_CERT
PATH_TO_KEY = config.PATH_TO_KEY
PATH_TO_ROOT = config.PATH_TO_ROOT
TOPIC_SUBSCRIBE = config.TOPIC_CONTROL
TOPIC_PUB_EGAUGE = config.TOPIC_PUBLISH_EGAUGE
TOPIC_PUB_SONNEN = config.TOPIC_PUBLISH_SONNEN
# initialize client:
myAWSIoTMQTTClient = AWSIoTPyMQTT.AWSIoTMQTTClient(CLIENT_ID)
myAWSIoTMQTTClient.configureEndpoint(ENDPOINT, 8883)
myAWSIoTMQTTClient.configureCredentials(PATH_TO_ROOT, PATH_TO_KEY, PATH_TO_CERT)
mqtt_connect = False
while not(mqtt_connect):
    mqtt_connect = myAWSIoTMQTTClient.connect()
    print(mqtt_connect)

# Initialize egauge obj
egauge_ip = '198.129.116.113'
egauge_obj = egauge_local_api.EgaugeInterface(mode='ip', endpoint=egauge_ip, topic=config.TOPIC_PUBLISH_EGAUGE,
                                              clientid=CLIENT_ID)
# Initialize sonnen obj
sonnen_obj = sonnen_local_api.SonnenLocalApi(clientid=CLIENT_ID, topic=config.TOPIC_PUBLISH_SONNEN)

while True:
    der_data = {'egauge_obj': egauge_obj,
                'sonnen_obj': sonnen_obj,
                'mqtt_client': myAWSIoTMQTTClient}

    pubsubClass.do_every(4, pubsubClass.publish2topic, **der_data)