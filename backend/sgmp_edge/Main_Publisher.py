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

# Define the correspondance between device type and the class
device_types = {
    'sonnen': sonnen_local_api.SonnenLocalApi,
    'egauge': egauge_local_api.EgaugeInterface
}

# This function populates the device list with a object instance of the corresponding type
def instantiate_devices(devices):
    for device in devices:
        device['instance'] = device_types[device['type']](device['config'])
    return devices

# Read device config
devices = []
with open('devices.json', 'r') as devices_file:
    devices = json.loads(devices_file.read())['devices']

# This is used when new device list is being received
new_devices_lock = threading.Lock()
new_devices = None

# Instantiate a device instance for each device
instantiate_devices(devices)

def collect_and_publish():
    timestamp = int(round(time.time() * 1000))
    def device_func(device):
        topic = 'gismolab_sgmp_read/' + str(device['device_id']) + '/' + str(timestamp) + '/data'
        if config.DRY_RUN:
            print('Dry run: read and publish data to %s' % topic)
            return
        result = device['instance'].read()
        print('[%s]' % topic, result)
        mqtt.publish(topic, json.dumps(result), QoS=1)

    threads = [threading.Thread(target=device_func, args=(device,)) for device in devices]
    for th in threads:
        th.start()
    for th in threads:
        th.join()

# Subscribe to config update action
def config_update_callback(client, userdata, message):
    global new_devices, new_devices_lock
    print('Received config update!')
    new_devices_lock.acquire()
    new_devices = json.loads(message.payload.decode('utf-8'))
    with open('devices.json', 'w') as devices_file:
        json.dump({'devices': new_devices}, devices_file)
    new_devices_lock.release()

mqtt.subscribe('gismolab_sgmp_config/devices', QoS=1, callback=config_update_callback)

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
        continue
    # Check if new devices are pushed
    new_devices_lock.acquire()
    if new_devices is not None:
        th.join()
        devices = new_devices
        new_devices = None
        instantiate_devices(devices)
    new_devices_lock.release()