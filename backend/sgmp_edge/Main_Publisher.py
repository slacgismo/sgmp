'''This function will be running on the RPi'''

import json
import config
import time
import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT
import egauge_local_api
import sonnen_local_api
import powerflex_remote_api
import threading
import logging
from common import ReadResult, Reading

# Initialize logging facility
logger = logging.getLogger('sgmp')
logger.setLevel(logging.DEBUG)

handler = logging.StreamHandler()
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s [%(name)s][%(levelname)s] %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

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

logger.info('My client ID is: %s' % CLIENT_ID)
while not(mqtt_connect):
    mqtt_connect = mqtt.connect()
    logger.info('Trying to connect with AWS IoT MQTT Service...')
    time.sleep(1)

logger.info('Connected to AWS IoT MQTT!')

# Define the correspondance between device type and the class
device_types = {
    'sonnen': sonnen_local_api.SonnenLocalApi,
    'egauge': egauge_local_api.EgaugeInterface,
    'powerflex': powerflex_remote_api.PowerflexRemoteApi
}

# This function populates the device list with a object instance of the corresponding type
def instantiate_devices(devices):
    logger.info('Refereshing device configuration...')
    for device in devices:
        logger.info('Device ID %s, name %s, type %s' % (device['device_id'], device['name'], device['type']))
        if device['type'] not in device_types:
            logger.warning('Device type %s is not recognized!' % device['type'])
            continue
        device['instance'] = device_types[device['type']](device['config'])
    logger.info('Refresh done')
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

# This function will be called periodically to collect and publish readings
def collect_and_publish():
    # Aligned timestamp for all devices
    timestamp = int(round(time.time() * 1000))
    def device_func(device):
        # The topic we want to publish to
        topic = config.DEPLOYMENT_NAME + '_read/' + config.CLIENT_ID + '/' + str(device['device_id']) + '/' + device['name'] + '/' + str(timestamp) + '/data'

        # If under dry run mode, don't perform the actual operations
        if config.DRY_RUN:
            logger.info('Dry run: read and publish data to %s' % topic)
            return

        try:
            # Invoke read method of the device instance
            if 'instance' not in device:
                raise Exception('device not instantiated')
            result = device['instance'].read()
        except Exception as e:
            # Stop if we encounter an exception
            logger.warning('Can\'t read from device %s: %s' % (device['name'], e))
            return

        # Publish to MQTT
        if isinstance(result, ReadResult):
            # Device returns a list of Readings
            if len(result.readings) == 0:
                logger.info('Device %s didn\'t return any new readings' % (device['name']))
            for reading in result.readings:
                topic = config.DEPLOYMENT_NAME + '_read/' + config.CLIENT_ID + '/' + str(device['device_id']) + '/' + device['name'] + '/' + str(reading.timestamp) + '/data'
                logger.info('Multi-Publish [%s] %s' % (topic, reading.data))
                mqtt.publish(topic, json.dumps(reading.data), QoS=1)
            for event in result.events:
                topic = config.DEPLOYMENT_NAME + '_read/' + config.CLIENT_ID + '/' + str(device['device_id']) + '/' + device['name'] + '/' + str(event.timestamp) + '/event'
                event_dict = {
                    'type': event.type,
                    'data': event.data
                }
                logger.info('Event [%s] %s' % (topic, event_dict))
                mqtt.publish(topic, json.dumps(event_dict), QoS=1)
        else:
            logger.info('Publish [%s] %s' % (topic, result))
            mqtt.publish(topic, json.dumps(result), QoS=1)

    # Spawn one thread for each device
    threads = [threading.Thread(target=device_func, args=(device,)) for device in devices]
    for th in threads:
        th.start()
    # Wait for the threads to finish
    for th in threads:
        th.join()

# Subscribe to config update action
def config_update_callback(client, userdata, message):
    global new_devices, new_devices_lock
    logger.info('Received config update!')
    new_devices_lock.acquire()
    new_devices = json.loads(message.payload.decode('utf-8'))
    with open('devices.json', 'w') as devices_file:
        json.dump({'devices': new_devices}, devices_file)
    new_devices_lock.release()

mqtt.subscribe('%s_config/%s/devices' % (config.DEPLOYMENT_NAME, config.CLIENT_ID), QoS=1, callback=config_update_callback)

terminate = False
while not terminate:
    th = threading.Thread(target=collect_and_publish)
    th.start()
    try:
        time.sleep(4)
    except KeyboardInterrupt:
        logger.info('Received KeyboardInterrupt. Please wait while the publisher finishes its tasks.')
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