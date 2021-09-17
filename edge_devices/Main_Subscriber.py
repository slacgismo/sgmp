'''This function will be running on the RPi'''

import pubsubClass
import config
import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT
import time as t

CLIENT_ID = config.CLIENT_ID_CONTROL
ENDPOINT = config.ENDPOINT
PATH_TO_CERT = config.PATH_TO_CERT
PATH_TO_KEY = config.PATH_TO_KEY
PATH_TO_ROOT = config.PATH_TO_ROOT
TOPIC_SUBSCRIBE = config.TOPIC_CONTROL

# initialize client:
myAWSIoTMQTTClient = AWSIoTPyMQTT.AWSIoTMQTTClient(CLIENT_ID)
myAWSIoTMQTTClient.configureEndpoint(ENDPOINT, 8883)
myAWSIoTMQTTClient.configureCredentials(PATH_TO_ROOT, PATH_TO_KEY, PATH_TO_CERT)
mqtt_connect = False
while not(mqtt_connect):
    mqtt_connect = myAWSIoTMQTTClient.connect()
    print(mqtt_connect)

pubsubClass.subscribe(myAWSIoTMQTTClient,TOPIC_SUBSCRIBE, 'sonnen_act')

while True:
    t.sleep(1)
