import requests
import time
import pandas as pd
from common import Reading

class PowerflexRemoteApi():
    def __init__(self, config):
        self.config = config
        self.base_headers = {"cache-control": "no-cache", "content-type": "application/json"}
        self.last_timestamp = 0

    def read(self):
        now = int(time.time())
        result = {}

        access_token = ''
        login_payload = {"username": self.config['username'], "password": self.config['password']}
        r = requests.post(self.config['url'] + '/login', headers=self.base_headers, json=login_payload)
        if r.status_code == requests.codes.ok:
            access_token = r.json()["access_token"]
        else:
            raise Exception('Cannot log in to Powerflex API, status code = %d' % r.status_code)

        authorized_headers = self._get_authorized_headers(access_token)
        interval_payload = {'measurement': 'ct_response', 'time_filter': [now-10, now]}
        r = requests.post(self.config['url'] + '/get_measurement_data', headers=authorized_headers, json=interval_payload)
        if r.status_code == requests.codes.ok:
            data = r.json()
        else:
            raise Exception('Cannot read Powerflex API, status code = %d' % r.status_code)

        columns = data["data"]["results"][0]["series"][0]["columns"]
        df = pd.DataFrame(data=data["data"]["results"][0]["series"][0]["values"], columns=columns)
        df = df[(df['acc_id'] == self.config['acc_id']) & (df['acs_id'] == self.config['acs_id']) & (df['time'] > self.last_timestamp)]
        df.reset_index(drop=True, inplace=True)
        df = df[['time', 'acc_id', 'acs_id', 'charging_state', 'energy_delivered', 'mamps_actual',
                 'pilot_actual', 'power', 'voltage']]
        results = df.sort_values(by=['time'], ascending=False).to_dict(orient='record')
        if len(results) == 0:
            return []
        
        self.last_timestamp = results[0]['time']
        ret = []
        for row in results:
            ret.append(Reading(row['time'] * 1000, row))
        return ret

    def act(self, data):
        pass

    def _get_authorized_headers(self, token):
        ret = self.base_headers
        ret["Authorization"] = f"Bearer {token}"
        return ret