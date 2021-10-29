import requests
import time
import pandas as pd
from common import Event, ReadResult, Reading

class PowerflexRemoteApi():
    def __init__(self, config):
        self.config = config
        self.base_headers = {"cache-control": "no-cache", "content-type": "application/json"}
        self.last_timestamp = 0
        self.last_start_timestamp = 0
        self.charging_state = ''

    def read(self):
        now = int(time.time())
        result = ReadResult()

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
        results = df.sort_values(by=['time'], ascending=True).to_dict(orient='record')
        if len(results) == 0:
            return result
        
        self.last_timestamp = results[-1]['time']
        ret = []
        for row in results:
            ret.append(Reading(row['time'] * 1000, row))
        result.readings = ret

        events = []
        for row in results:
            if self.charging_state == '':
                self.charging_state = row['charging_state']
            if self.charging_state == 'UNPLUGGED' and row['charging_state'] != 'UNPLUGGED':
                # started charging
                events.append(Event(row['time'] * 1000, 'EV_START_CHARGING', {}))
                self.last_start_timestamp = row['time']
            elif self.charging_state != 'UNPLUGGED' and row['charging_state'] == 'UNPLUGGED':
                # ended charging
                ts = row['time']
                if self.last_start_timestamp != 0:
                    events.append(Event(ts * 1000, 'EV_END_CHARGING', {'duration': (ts - self.last_start_timestamp) * 1000, 'energy': row['energy_delivered']}))
            self.charging_state = row['charging_state']
        result.events = events
        
        return result

    def act(self, data):
        pass

    def _get_authorized_headers(self, token):
        ret = self.base_headers
        ret["Authorization"] = f"Bearer {token}"
        return ret