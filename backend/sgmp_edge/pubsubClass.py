import config
import time
import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT
import json
import sonnen_local_api
import egauge_local_api


def publish(client, topic, payload, Device_ID):
    payload = {'DeviceID': Device_ID, 'DeviceInformation': payload}
    try:
        client.publish(topic, json.dumps(payload), 1)
    except Exception as e:
        print('Publish error: ', e)
    print("Message published in topic: ", topic)
    # print(payload)

def do_every(period,f,**kwargs):
    def g_tick():
        t = time.time()
        while True:
            t += period
            yield max(t - time.time(),0)
    g = g_tick()
    while True:
        time.sleep(next(g))
        f(**kwargs)

def publish2topic(**der_data):
    # der_data = {'egauge_info':['eg_client', 'eg_topic', 'eg_payload', 'eg_devID'],
    # 'sonnen_info': ['so_client', 'so_topic', 'so_payload', 'so_devID'],
    # 'sonnen_dc':['dc_client', 'dc_topic', 'dc_payload', 'dc_devID']}
    egauge_params = der_data['egauge_info']
    try:
        egauge_params[0].publish(egauge_params[1], json.dumps(egauge_params[2]), 1)
        print("Message published in topic: ", egauge_params[1])
    except Exception as e:
        print('Publish error in egauge: ', e)

    sonnen_params = der_data['sonnen_info']
    try:
        sonnen_params[0].publish(sonnen_params[1], json.dumps(sonnen_params[2]), 1)
        print("Info message published in topic: ", sonnen_params[1])
    except Exception as e:
        print('Publish error in sonnen_info: ', e)

    sonnenDC_params = der_data['sonnen_dc']
    try:
        sonnenDC_params[0].publish(sonnenDC_params[1], json.dumps(sonnenDC_params[2]), 1)
        print("DC message published in topic: ", sonnenDC_params[1])
    except Exception as e:
        print('Publish error in sonnen_dc: ', e)

# Get config of device from devices.json by supplying name
def get_device_config(device_name):
    with open('devices.json', 'r') as devices_file:
        devices = json.loads(devices_file.read())['devices']
        device_config = [device for device in devices if device["name"] == "sonnen"][0]["config"]
    return device_config

battery_config = get_device_config("sonnen")

def subscribe(client, topic, method):
    if method == 'sonnen_act':
        client.subscribe(topic, 1, sonnenCallback)
    else:
        client.subscribe(topic, 1, customCallback)

def sonnenCallback(client, userdata, message):
    print('sonnen callback function')
    retval = json.loads(message.payload.decode('utf-8'))
    try:
        for device in retval['DeviceInformation']:
            if device['resource'] == "battery":
                sonnen_obj = sonnen_local_api.SonnenLocalApi(battery_config)
                device['payload']['action'] = 'set_mode'
                latestPowerValue = device['payload']['power']
                device['payload']['power'] = -(round(abs(latestPowerValue) * 1000, 1)) if latestPowerValue < 0 else (round(abs(latestPowerValue) * 1000, 1))
                sonnen_obj.act(device['payload'])
                break
        else:
            print('No sonnen resource')
    except Exception as e:
        print('Error: ', e)

def customCallback(client, userdata, message):
    payload = json.loads(message.payload)
    print(payload)


if __name__ == "__main__":
    # AWS config
    ENDPOINT = config.ENDPOINT
    CLIENT_ID = config.CLIENT_ID
    PATH_TO_CERT = config.PATH_TO_CERT
    PATH_TO_KEY = config.PATH_TO_KEY
    PATH_TO_ROOT = config.PATH_TO_ROOT
    TOPIC_PUBLISH_EGAUGE = config.TOPIC_PUBLISH_EGAUGE
    TOPIC_PUBLISH_SONNEN = config.TOPIC_PUBLISH_SONNEN

    # AWS IoT client config
    myAWSIoTMQTTClient = AWSIoTPyMQTT.AWSIoTMQTTClient(CLIENT_ID)
    myAWSIoTMQTTClient.configureEndpoint(ENDPOINT, 8883)
    myAWSIoTMQTTClient.configureCredentials(PATH_TO_ROOT, PATH_TO_KEY, PATH_TO_CERT)
    mqtt_connect = False
    while not (mqtt_connect):
        mqtt_connect = myAWSIoTMQTTClient.connect()
        print('pubsubClass: ', mqtt_connect)

    # Initializing egauge and sonnen objects
    egauge_ip = '198.129.116.113'
    egauge_obj = egauge_local_api.EgaugeInterface(mode='ip', endpoint=egauge_ip,topic=TOPIC_PUBLISH_EGAUGE, clientid=CLIENT_ID)
    sonnen_obj = sonnen_local_api.SonnenLocalApi(clientid=CLIENT_ID, topic=TOPIC_PUBLISH_SONNEN)
    while True:
        do_every(4, egauge_obj.processing_egauge_data(), sonnen_obj.sonnen_publish())
