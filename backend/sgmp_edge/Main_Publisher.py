'''This function will be running on the RPi'''

import json
import config
import time
import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT
import egauge_local_api
import sonnen_local_api
import threading

CLIENT_ID = config.CLIENT_ID
ENDPOINT = config.ENDPOINT
PATH_TO_CERT = config.PATH_TO_CERT
PATH_TO_KEY = config.PATH_TO_KEY
PATH_TO_ROOT = config.PATH_TO_ROOT

# Initialize client
mqtt = AWSIoTPyMQTT.AWSIoTMQTTClient(CLIENT_ID)
mqtt.configureEndpoint(ENDPOINT, 8883)
mqtt.configureCredentials(PATH_TO_ROOT, PATH_TO_KEY, PATH_TO_CERT)
mqtt_connect = False

while not(mqtt_connect):
    mqtt_connect = mqtt.connect()
    print('Trying to connect with AWS IoT MQTT Service...')
    time.sleep(1)

print('Connected!')

# Read device configuration
device_types = {
    'sonnen': sonnen_local_api.SonnenLocalApi,
    'egauge': egauge_local_api.EgaugeInterface
}

devices = []
with open('devices.json', 'r') as devices_file:
    devices = json.loads(devices_file.read())['devices']

# Instantiate a device instance for each device
for device in devices:
    device['instance'] = device_types[device['type']](device['config'])

def collect_and_publish():
    timestamp = int(round(time.time() * 1000))
    def device_func(device):
        topic = 'gismolab_sgmp_read/' + str(device['device_id']) + '/' + str(timestamp) + '/data'
        result = device['instance'].read()
        print('[%s]' % topic, result)
        mqtt.publish(topic, json.dumps(result), QoS=1)

    threads = [threading.Thread(target=device_func, args=(device,)) for device in devices]
    for th in threads:
        th.start()
    for th in threads:
        th.join()

terminate = False
while not terminate:
    th = threading.Thread(target=collect_and_publish)
    th.start()
    try:
        time.sleep(4)
    except KeyboardInterrupt:
        print('Received KeyboardInterrupt. Please wait while the publisher finishes its tasks.')
        th.join()
        terminate = True