import csv
import datetime
import json
import time
from concurrent.futures import thread

import xmltodict
import requests
from requests.auth import HTTPDigestAuth
import threading


# This script is used for collecting input data for optimzer. This script will be
# running all the time, and write the data into files of the same directory.
class EgaugeInterface():

    def __init__(self, mode=None, endpoint=None, username=None, password=None, t_sample=1, topic=None, clientid=None):
        # Initializing credentials
        self.endpoint = endpoint
        self.mode = mode
        self.username = username
        self.password = password
        self.TOPIC_PUBLISH_EGAUGE = topic
        self.CLIENT_ID = clientid

        # Initializing parameters
        self.t_sample = t_sample
        self.keys = ["A.Battery", "A.SubPanel", "A.GridPower", "A.Solar", "A.EV", "ts"]

    def fetch_egauge_data(self):
        url = 'http://' + self.endpoint + '/cgi-bin/egauge?ins&tot'
        try:
            if self.mode == 'web':
                resp = requests.get(url, auth=HTTPDigestAuth(self.username, self.password))
            elif self.mode == 'ip':
                resp = requests.get(url)
            else:
                print('mode type not acceptable')
                return 'Error egauge: mode type not acceptable'

            resp.raise_for_status()
            data = self.get_egauge_registers(resp)

        except requests.exceptions.HTTPError as err:
            print(err)
            return None

        return data

    # Function to process data from e-gauge and convert to useful power values
    def processing_egauge_data(self):
        if self.endpoint is None:
            print('enpoint is None')
            return 'Error egauge: endpoint is none'

        power_values = dict.fromkeys(self.keys, None)
        data_ini = self.fetch_egauge_data()
        time.sleep(self.t_sample)
        data_end = self.fetch_egauge_data()
        ts_delta = data_end['ts'] - data_ini['ts']

        try:
            for i in power_values:
                if i == 'ts':
                    power_values['ts'] = datetime.datetime.fromtimestamp(int(data_end['ts'])).strftime(
                        '%Y-%m-%d %H:%M:%S')
                else:
                    power_values[i] = round(((data_end[i] - data_ini[i]) / ts_delta) / 1000, 3)

            return power_values
        except Exception as e:
            print('Error retrieving data from E-Gauge API: ', e)
            return ('Error egauge: mode type not acceptable', e)

    def get_egauge_registers(self, response):
        power_values = dict.fromkeys(self.keys, None)
        data = xmltodict.parse(response.text)
        data_json = json.loads(json.dumps(data))
        keys_set = self.keys
        if data_json['data']['ts'] != None:
            power_values['ts'] = int(data_json['data']['ts'])
        egauge_vals = data_json['data']['r']

        for i in egauge_vals:
            if i['@n'] in keys_set:
                power_values[i['@n']] = int(i['v'])

        return power_values


def collect_daily_data(period, mode, user, endpoint, password, filename):
    f = open(filename, 'a')
    writer = csv.writer(f)
    egauge_obj = EgaugeInterface(mode=mode, endpoint=endpoint, username=user, password=password)

    def g_tick():
        t = time.time()
        while True:
            t += period
            yield max(t - time.time(), 0)

    g = g_tick()
    while True:
        time.sleep(next(g))
        try:
            power_values = egauge_obj.processing_egauge_data()
            writer.writerow(power_values.values())  # write a row to the csv file
        except Exception as ex:
            print(ex)

    # close the file
    f.close()


# run the script to collect input data for optimizer every second
if __name__ == "__main__":
    user = 'gismolab'
    password = 'slacGISMO'
    url240 = 'https://egauge47573.egaug.es/cgi-bin/egauge'
    mode = 'web'
    houseB_endpoint = 'egauge47571.egaug.es/'  # house B
    houseA_endpoint = 'egauge47570.egaug.es/'  # house A
    period = 60

    # thread_houseA = threading.Thread(target=collect_daily_data,
    #                                  args=(period, mode, user, houseA_endpoint, password, 'houseA_input.csv'))
    thread_houseB = threading.Thread(target=collect_daily_data,
                                     args=(period, mode, user, houseB_endpoint, password, 'houseB_input.csv'))

    # thread_houseA.start()
    thread_houseB.start()

    # thread_houseA.join()
    thread_houseB.join()
