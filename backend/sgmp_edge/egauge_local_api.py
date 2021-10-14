
import datetime
import requests
import time
import json
import xmltodict

class EgaugeInterface():

    def __init__(self, config):
        # Initializing parameters
        if 't_sample' not in config:
            config['t_sample'] = 5

        self.config = config

    # Function to process data from e-gauge and convert to useful power values
    def read(self):
        url = 'http://' + self.config['ip'] + '/cgi-bin/egauge?ins&tot'
        power_values = dict.fromkeys(self.config['keys'], None)

        try:
            resp = requests.get(url, timeout=2)
            resp.raise_for_status()

            data_ini = self.get_egauge_registers(resp)
        except requests.exceptions.HTTPError as err:
            print(err)
            return power_values

        time.sleep(self.config['t_sample'])

        try:
            resp = requests.get(url, timeout=2)
            resp.raise_for_status()

            data_end = self.get_egauge_registers(resp)
        except requests.exceptions.HTTPError as err:
            print(err)
            return power_values

        ts_delta = data_end['ts'] - data_ini['ts']
        try:
            for i in power_values:
                if i == 'ts':
                    power_values['ts'] = datetime.datetime.fromtimestamp(int(data_end['ts'])).strftime('%Y-%m-%d %H:%M:%S')
                else:
                    power_values[i] = round(((data_end[i] - data_ini[i]) / ts_delta) / 1000, 3)

            return power_values
        except Exception as e:
            print('Error retrieving data from E-Gauge API: ', e)
            return power_values

    def act(self, data):
        # Does nothing
        return

    def get_egauge_registers(self, response):
        power_values = dict.fromkeys(self.config['keys'], None)
        data = xmltodict.parse(response.text)
        data_json = json.loads(json.dumps(data))
        keys_set = self.config['keys']
        if data_json['data']['ts'] != None:
            power_values['ts'] = int(data_json['data']['ts'])
        egauge_vals = data_json['data']['r']

        for i in egauge_vals:
            if i['@n'] in keys_set:
                power_values[i['@n']] = int(i['v'])

        return power_values
