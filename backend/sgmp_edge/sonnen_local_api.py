
import requests
from datetime import datetime

class SonnenLocalApi():
    def __init__(self, config):
        self.config = config

    def read(self):
        now = datetime.now()
        result = {}
        result['timestamp'] = now.strftime("%d/%m/%Y %H:%M:%S")
        try:
            url = 'http://' + self.config['ip'] + ':8080/api/battery'
            response = requests.get(url)
            response.raise_for_status()
            result['battery'] = response.json()
        except requests.exceptions.HTTPError as err:
            print(err)
            result['error'] = err
            return result

        try:
            url = 'http://' + self.config['ip'] + ':8080/api/v1/status'
            response = requests.get(url)
            response.raise_for_status()
            result['status'] = response.json()
        except requests.exceptions.HTTPError as err:
            print(err)
            result['error'] = err
            return result

        return result

    def act(self, data):
        if data['action'] == 'set_mode':
            mode_dict = {
                'manual': 'http://' + self.config['ip'] + ':8080/api/setting/?EM_OperatingMode=1',
                'self': 'http://' + self.config['ip'] + ':8080/api/setting/?EM_OperatingMode=8'
            }

            try:
                response = requests.get(mode_dict[data['mode']])
                response.raise_for_status()
            except requests.exceptions.HTTPError as err:
                print(err)
                return

            if data['mode'] == 'manual':
                value = 0
                if 'value' in data['mode']: value = data['mode']
                self.batt_act(value)
            
        elif data['action'] == 'batt_act':
            self.batt_act(data['value'])

    def batt_act(self, value=0):
        now = datetime.now()
        url = 'http://' + self.config['ip'] + ':8080/api/v1/setpoint/'
        if int(value) > 0:
            url = url + 'discharge/' + str(abs(value))
            try:
                dis_response = requests.get(url)
                print('discharge response: ', dis_response.json())
                dis_response.raise_for_status()
            except requests.exceptions.HTTPError as err:
                print('Error discharging')
                print(err)
                return ('Error discharging', err)
        else:
            url = url + 'charge/' + str(abs(value))
            try:
                cha_response = requests.get(url)
                print('charging response: ', cha_response.json())
                cha_response.raise_for_status()
            except requests.exceptions.HTTPError as err:
                print('Error charging')
                print(err)
                return ('Error charging', err)
        return {'timestamp': now.strftime("%d/%m/%Y %H:%M:%S"), 'mode': self.mode, 'value': value}
