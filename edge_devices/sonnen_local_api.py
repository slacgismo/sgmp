
import requests
import config
from datetime import datetime

class SonnenLocalApi():
    def __init__(self, clientid=None, topic=None):
        # sonnen config
        #TODO: Think about making these inputs to the class
        self.URL_BATT_INFO = config.URL_BATT_INFO
        self.URL_BATT_SETPOINT = config.URL_BATT_SETPOINT
        self.URL_MANUAL_MODE = config.URL_MANUAL_MODE
        self.HEADERS_SONNEN = config.HEADERS_SONNEN
        self.PAYLOAD_SONNEN = config.PAYLOAD_SONNEN
        self.URL_SELF_CONS = config.URL_SELF_CONS
        self.URL_STATUS = config.URL_STATUS
        self.mode = 'not_defined'
        self.TOPIC_PUBLISH_SONNEN = topic
        self.CLIENT_ID = clientid

    def batt_info(self,):
        now = datetime.now()
        try:
            response = requests.request("GET", self.URL_BATT_INFO, headers=self.HEADERS_SONNEN, data=self.PAYLOAD_SONNEN)
            response.raise_for_status()
            payload = response.json()
            payload['timestamp'] = now.strftime("%d/%m/%Y %H:%M:%S")
            return payload
        except requests.exceptions.HTTPError as err:
            print(err)
            payload['Error'] = err
            payload['timestamp'] = now.strftime("%d/%m/%Y %H:%M:%S")
            return payload

    def batt_mode(self, mode='self', value='0'):
        # need to finalize: 1) adding other modes, 2) final return, 3) try/except conditions
        mode_dict = {'manual': self.URL_MANUAL_MODE, 'self': self.URL_SELF_CONS, 'status': self.URL_STATUS}
        now = datetime.now()
        if mode in mode_dict:
            # Check for previous state of battery mode
            if self.mode != 'manual':
                try:
                    response = requests.request("GET", mode_dict[mode], headers=self.HEADERS_SONNEN,
                                                data=self.PAYLOAD_SONNEN)
                    response.raise_for_status()
                    self.mode = mode
                except requests.exceptions.HTTPError as err:
                    print('Error in mode: ', mode_dict[mode])
                    print(err)
                    return ('Error battery mode',err)
                # If the new mode is manual actuate the battery
                if mode == 'manual':
                    return(self.batt_act(value=value))
                else:
                    return {'timestamp': now.strftime("%d/%m/%Y %H:%M:%S"), 'mode': mode, 'data': response.json()}
            else:
                if self.mode == mode:
                    # Battery is already in manual mode. Just need to actuate
                    self.batt_act(value=value)
                else:
                    try:
                        response = requests.request("GET", mode_dict[mode], headers=self.HEADERS_SONNEN,
                                                    data=self.PAYLOAD_SONNEN)
                        response.raise_for_status()
                        self.mode = mode
                    except requests.exceptions.HTTPError as err:
                        print('Error in mode: ', mode_dict[mode])
                        print(err)
                        return ('Error battery mode', err)
                    return {'timestamp': now.strftime("%d/%m/%Y %H:%M:%S"), 'mode': mode, 'data':response.json()}
        else:
            print('mode not valid')
            return 'mode not valid'

    def batt_act(self,value='0'):
        now = datetime.now()
        if int(value) > 0:
            URL_DISCHARGE = self.URL_BATT_SETPOINT + 'discharge/' + str(abs(int(value)))
            try:
                dis_response = requests.request("GET", URL_DISCHARGE, headers=self.HEADERS_SONNEN,
                                                data=self.PAYLOAD_SONNEN)
                print('discharge response: ', dis_response.json())
                dis_response.raise_for_status()
            except requests.exceptions.HTTPError as err:
                print('Error discharging')
                print(err)
                return ('Error discharging', err)
        else:
            URL_CHARGE = self.URL_BATT_SETPOINT + 'charge/' + str(abs(int(value)))
            try:
                cha_response = requests.request("GET", URL_CHARGE, headers=self.HEADERS_SONNEN,
                                                data=self.PAYLOAD_SONNEN)
                print('charging response: ', cha_response.json())
                cha_response.raise_for_status()
            except requests.exceptions.HTTPError as err:
                print('Error charging')
                print(err)
                return ('Error charging', err)
        return {'timestamp': now.strftime("%d/%m/%Y %H:%M:%S"), 'mode': self.mode, 'value': value}

if __name__ == "__main__":
    sonnen = SonnenLocalApi()
    print(sonnen.batt_mode(mode='status'))