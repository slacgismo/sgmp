import sonnen_local_api
import time
import json
import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT
import config


# TODO: Make this a class and keep adding new tests

ENDPOINT = config.ENDPOINT
CLIENT_ID = config.CLIENT_ID_WEB
PATH_TO_CERT = config.PATH_TO_CERT
PATH_TO_KEY = config.PATH_TO_KEY
PATH_TO_ROOT = config.PATH_TO_ROOT
TOPIC_PUBLISH = config.TOPIC_CONTROL

def publish(client, topic, payload, Device_ID):
    payload = {'DeviceID': Device_ID, 'DeviceInformation': payload}
    try:
        client.publish(topic, json.dumps(payload), 1)
    except Exception as e:
        print('Publish error: ', e)
    print("Message published: ")
    print(payload)
    # client.disconnect() # Figure out if need to disconnect or not -> best pratices

def pulse_train(period=2, width=3, power=1000, mode='local', wu='n'):
    print(period,power,mode,wu)
    if power > 0:
        power_low = '400'
    else:
        power_low = '-400'

    power_high = power
    if mode == 'local':
        print('Local Mode in batt_tests')
        if wu == 'y':
            p_init = '500'
            sonnen_obj = sonnen_local_api.SonnenLocalApi()
            sonnen_obj.batt_mode(mode='manual', value=p_init)
            time.sleep(60)
        else:
            p_init = '0'
            sonnen_obj = sonnen_local_api.SonnenLocalApi()
            sonnen_obj.batt_mode(mode='manual', value=p_init)
        print('Local run successful')

        retval_time = []
        retval_power = []
        i = 0
        while int(time.time()) % width != 0:
            pass
        print('main function in unix time: ', int(time.time()))
        while period > i:
           while int(time.time()) % width != 0:
               pass
           sonnen_obj.batt_act(value=power_low)
           retval_time.append(int(time.time()))
           retval_power.append(power_low)
           time.sleep(1)
           while int(time.time()) % width != 0:
               pass
           sonnen_obj.batt_act(value=str(power_high))
           retval_time.append(int(time.time()))
           retval_power.append(power_high)
           i += 1
           time.sleep(1)
        # account for last time period before changing to self consumption
        print(width-1)
        time.sleep(width-1)
        # returning battery to self consumption mode
        sonnen_obj.batt_mode(mode='self')
        print(retval_time)
        print(retval_power)
        return(retval_time, retval_power)
    elif mode == 'web':
        print('publish the values of period, width and power to topic')
        pulse_info = (period, width, power, wu)
        payload = {"resource": "sonnen", "payload": pulse_info}
        myAWSIoTMQTTClient = AWSIoTPyMQTT.AWSIoTMQTTClient(CLIENT_ID)
        myAWSIoTMQTTClient.configureEndpoint(ENDPOINT, 8883)
        myAWSIoTMQTTClient.configureCredentials(PATH_TO_ROOT, PATH_TO_KEY, PATH_TO_CERT)
        mqtt_connect = False
        while not (mqtt_connect):
            mqtt_connect = myAWSIoTMQTTClient.connect()
            print(mqtt_connect)
        publish(myAWSIoTMQTTClient,TOPIC_PUBLISH,payload,CLIENT_ID)
        print('Web mode. Message published to topic')

    else:
        print('mode not valid')
        return{'retval':'Unsucessful', 'code':'mode not valid'}

if __name__ == "__main__":
    while True:
        mode = input('Please answer "local", if you are in the GismoLab, or "web", if you are not in the GismoLab:')
        input('Provide pulse train information. Hit Enter')
        period = input('How many pulses (integer) you want to test?')
        width = input('What is the time duration (in seconds) of each pulse?')
        power = input('What is the power (in Watts) of the pulses')
        wu = input('Do you want to warm-up the battery, first? (y/n)')
        input('Your test will start 60 seconds after the message is received. Hit Enter to continue...')
        pulse_train(mode=mode, period=int(period), width=int(width), power=int(power), wu=wu)
        # pulse_train(mode=mode, period=int(period), width=int(width), power=int(power), wu=wu)
        # if mode == 'local':
        #     pulse = pulse_train(period=int(period),width=int(width),power=int(power),mode=mode, wu=wu)
        # elif mode == 'web':
        #     pulse = pulse_train(period=int(period), width=int(width), power=int(power), mode=mode)
        #     print('Check Main_Subscriber to see if message was received')
