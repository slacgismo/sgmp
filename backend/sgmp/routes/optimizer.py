# TODO:
#   Add demand charges
#   Add solar forecast
#   Add EV control (need to fix PF API)
#   Add EV arrival/departure model
#   Add robust MPC
#   Add PID within the battery command
import datetime
import json
import time
import xmltodict
import pandas as pd
import numpy as np
import cvxpy as cvx
import requests
from matplotlib import pyplot as plt
# to make plots interactive go to PyCharm > Preferences > Python Scientific > disable Show plots in tool window
from requests.auth import HTTPDigestAuth


def generate_results():
    df_egauge = pd.read_csv('../../../../Lab_05_17.csv')
    df_egauge['Timestamp'] = pd.to_datetime(df_egauge['Date & Time'], errors='coerce')
    egauge = df_egauge.set_index('Timestamp')
    egauge.drop(columns='Date & Time', inplace=True)
    egauge.sort_index(inplace=True)

    data = egauge[1:]

    solar = egauge['A.Solar [kW]']  # >= 0 -> changed to negative
    solar.mask((abs(solar) <= 0.01), 0, inplace=True)
    battery = egauge['A.Battery [kW]']  # > 0 when discharging; < 0 when charging -> flipped the signal convention
    battery.mask((abs(battery) <= 0.01), 0, inplace=True)
    grid = egauge['A.GridPower [kW]']  # > 0 when exporting; < 0 when importing -> flipped the signal convention
    grid.mask((abs(grid) <= 0.01), 0, inplace=True)
    ev = egauge['A.EV [kW]']  # <= 0 -> changed to positive
    ev.mask((abs(ev) <= 0.01), 0, inplace=True)
    load = egauge['A.Load [kW]']  # <= 0 -> changed to positive
    load.mask((abs(load) <= 0.01), 0, inplace=True)

    # Data preprocessing
    # Solar:
    print('NaN within the dataset: ')
    print(solar.isna().sum())
    solar.fillna(method='ffill', inplace=True)
    solar = solar * (-1.0)
    # Battery:
    print('NaN within the dataset: ')
    print(battery.isna().sum())
    battery.fillna(method='ffill', inplace=True)
    battery = battery * (-1)
    # Grid:
    print('NaN within the dataset: ')
    print(grid.isna().sum())
    grid.fillna(method='ffill', inplace=True)
    grid = grid * (-1)
    # EV:
    print('NaN within the dataset: ')
    print(ev.isna().sum())
    ev.fillna(method='ffill', inplace=True)
    ev = ev * (-1)
    # Load:
    print('NaN within the dataset: ')
    print(load.isna().sum())
    load.fillna(method='ffill', inplace=True)
    load = load * (-1)

    plt.figure()
    plt.plot(solar)
    plt.plot(battery, 'b')
    plt.plot(ev, 'g')
    plt.plot(grid, 'k')
    plt.plot(load, 'r')
    plt.legend(['Solar', 'Battery', 'EV', 'Grid', 'Load'])
    plt.title('Original data')
    plt.show()

    net_load_original = solar[0:1440] + battery[0:1440] + ev[0:1440]

    ## Electricity price
    # PG&E E-19
    # demand_charges = [(20, np.concatenate((np.arange(int(16 * 4), int(24 * 4)), np.arange(int(0 * 4), int(6 * 4))))),  (2, np.arange(0, int(24 * 4)))]
    # energy_charges = [(0, np.arange(int(11 * 4), int(15 * 4))), (0.05, np.concatenate((np.arange(int(9 * 4), int(11 * 4)), np.arange(int(15 * 4), int(17 * 4))))), (0.1, np.arange(int(7 * 4), int(9 * 4))), (0.15, np.concatenate((np.arange(0, int(7 * 4)), np.arange(int(17 * 4), int(24 * 4)))))]

    # Optimization formulation
    day = 1  # number of days
    hr = 24  # number of hours
    t_res = 1 / 60  # time resolution: 1 minute
    T = 60 * hr * day

    ## PG&E Residential TOU (E-TOU-C)
    # Currently for just one day -> need to expand to two days or more days
    # energy_charges = [(0.34, np.arange(int(0*60), int(16*60))), (0.40, np.arange(int(16*60), int(21*60))), (0.34, np.arange(int(21*60), int(24*60)))]
    energy_charges = np.arange(0.0, 24.0 * 60)
    energy_charges[0:16 * 60] = 0.34 * t_res
    energy_charges[16 * 60:21 * 60] = 0.40 * t_res
    energy_charges[21 * 60:] = 0.34 * t_res
    backfeed_charges = np.arange(0.0 * 60, 24.0 * 60)
    backfeed_charges[:] = 0.1 * t_res

    # decision variables:
    c = cvx.Variable(T)  # charge rate
    # d = cvx.Variable(T) # discharge rate

    # other variables:
    Q = cvx.Variable(T + 1)  # battery charge level. First entry should be a constant -> Energy

    # constraints:
    c_max = 8.0  # maximum charging rate (8kW)
    c_min = -8.0  # minimum charging rate (200W) - change this to zero and see how it performs (latency in starting the unit)
    # d_min = 0.0 # maximum charging rate (8kW)
    # d_max = 8.0 # minimum charging rate (200W) - change this to zero and see how it performs (latency in starting the unit)

    Q_max = 10.0  # Maximum energy 10kWh
    Q_min = Q_max * 0.05  # Minimum energy allowed: 5% of maximum
    Q0 = 10.0  # Initial energy
    gamma_c = 1  # battery efficiency -> assuming charging/discharging have the same efficiency

    constraints = [
        c >= c_min,
        c <= c_max,
        # d <= d_max,
        # d >= d_min,
        Q >= Q_min,
        Q <= Q_max,
        Q[0] == Q0,
        Q[-1] == 0.4 * Q0,
        Q[1:(T + 1)] == Q[0:T] + c[0:T] * gamma_c * t_res
        # Q[1:(T+1)] == Q[0:T] + c[0:T]*gamma_c*t_res - d[0:T]*gamma_c*t_res
    ]

    P = solar[0:1440] + ev[0:1440]  # taking one day of data
    # P0 = solar[0:1440] + ev[0:1440] + battery[0:1440] # taking one day of data
    # plt.figure()
    # plt.plot(P, 'b')
    # plt.legend(['Net load'])
    # plt.show()

    objective = energy_charges.reshape((1, energy_charges.size)) @ cvx.reshape(cvx.pos(P.values + c), (T, 1))
    # objective = energy_charges.reshape((1,energy_charges.size)) @ cvx.reshape(cvx.pos(P.values + c - d), (T, 1))
    objective += backfeed_charges.reshape((1, backfeed_charges.size)) @ cvx.reshape(cvx.neg(P.values + c), (T, 1))

    min = cvx.Minimize(objective)
    prob = cvx.Problem(min, constraints=constraints)
    prob.solve(solver=cvx.ECOS)
    print("Optimization status: ", prob.status)
    print("Cost: ", prob.value)

    batt = c.value
    # batt = c.value - d.value
    soe = Q.value

    plt.figure()
    plt.plot(P.values, 'b')
    plt.plot(c.value, 'g')
    # plt.plot(c.value - d.value, 'g')
    plt.plot(P.values + c.value, 'k')
    # plt.plot(P.values + c.value - d.value, 'k')
    plt.legend(['Load', 'Batt', 'Grid'])
    plt.show()

    plt.figure()
    plt.subplot(3, 1, 1)
    plt.plot(c.value, 'g')
    # plt.plot(c.value-d.value, 'b')
    plt.plot(solar[0:1440].values, 'r')
    plt.plot(ev[0:1440].values, 'b')
    plt.legend(['Battery Opt', 'Solar', 'Load'])
    plt.ylabel('kW')
    # plt.subplot(4,1,2)
    # plt.figure()
    # plt.plot(Q.value, 'b')
    # plt.legend(['SOE'])
    # plt.ylabel('kWh')
    plt.subplot(3, 1, 2)
    plt.plot(P.values + c.value, 'b')
    # plt.plot(P.values + c.value -d.value, 'b')
    plt.legend(['Net Load - Grid [Optimized]'])
    plt.ylabel('kW')
    plt.subplot(3, 1, 3)
    plt.plot(P + battery[0:1440], 'b')
    plt.plot(battery[0:1440], 'g')
    plt.legend(['Net Load - Grid [Non-optimized]', 'Battery No-Opt'])
    plt.ylabel('kW')
    plt.show()

    # plt.figure()
    # plt.plot(Q.value, 'b')
    # plt.legend(['SOE'])
    # plt.ylabel('kWh')
    # plt.show()

    net_opt = P.values + c.value
    original_cost = energy_charges.reshape((1, energy_charges.size)) @ -np.minimum(
        net_load_original.values.reshape(T, 1), 0)
    print("Cost WITHOUT opt: ", original_cost[0][0])
    optimized_cost = energy_charges.reshape((1, energy_charges.size)) @ -np.minimum(net_opt.reshape(T, 1), 0)
    print('Optimized Cost: ', optimized_cost)
    print("Cost WITH opt: ", prob.value)
    savings = -prob.value + original_cost[0][0]
    print("Percentage savings: ", savings / original_cost[0][0])


class EgaugeInterface():

    def __init__(self, mode=None, endpoint=None, username=None, password=None, t_sample=5, topic=None, clientid=None):
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

    # Function to process data from e-gauge and convert to useful power values
    def processing_egauge_data(self):
        if self.endpoint is None:
            print('enpoint is None')
            return 'Error egauge: endpoint is none'
        self.url = 'http://' + self.endpoint + '/cgi-bin/egauge?ins&tot'
        power_values = dict.fromkeys(self.keys, None)
        try:
            if self.mode == 'web':
                resp = requests.get(self.url, auth=HTTPDigestAuth(self.username, self.password))
            elif self.mode == 'ip':
                resp = requests.get(self.url)
            else:
                print('mode type not acceptable')
                return 'Error egauge: mode type not acceptable'

            resp.raise_for_status()
            data_ini = self.get_egauge_registers(resp)

        except requests.exceptions.HTTPError as err:
            print(err)
            return json.dumps(power_values)

        time.sleep(self.t_sample)

        try:
            if self.mode == 'web':
                resp = requests.get(self.url, auth=HTTPDigestAuth(self.username, self.password))
                resp.raise_for_status()
            elif self.mode == 'ip':
                resp = requests.get(self.url)
                resp.raise_for_status()
            else:
                print('mode type not acceptable')
                return 'Error egauge: mode type not acceptable'

            data_end = self.get_egauge_registers(resp)

        except requests.exceptions.HTTPError as err:
            print(err)
            return json.dumps(power_values)

        ts_delta = data_end['ts'] - data_ini['ts']
        try:
            for i in power_values:
                if i == 'ts':
                    power_values['ts'] = datetime.datetime.fromtimestamp(int(data_end['ts'])).strftime(
                        '%Y-%m-%d %H:%M:%S')
                else:
                    power_values[i] = round(((data_end[i] - data_ini[i]) / ts_delta) / 1000, 3)

            # json_dict = json.dumps(power_values)
            # print('Data Dict: ', json_dict)
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

def do_every(period,f,**kwargs):
    def g_tick():
        t = time.time()
        while True:
            t += period
            yield max(t - time.time(),0)
    g = g_tick()
    while True:
        time.sleep(next(g))
        print(next(g))
        f(**kwargs)

def collect_daily_data(period):
    egauge_obj = EgaugeInterface(mode=mode, endpoint=endpoint, username=user, password=password)
    def g_tick():
        t = time.time()
        while True:
            t += period
            yield max(t - time.time(), 0)

    g = g_tick()
    while True:
        time.sleep(next(g))
        data = egauge_obj.processing_egauge_data()

def write_to_file(filename):
    pass

if __name__ == "__main__":
    user = 'gismolab'
    password = 'slacGISMO'
    url240 = 'https://egauge47573.egaug.es/cgi-bin/egauge'
    mode = 'web'
    endpoint = 'egauge47571.egaug.es/'  # house B
    # endpoint = egauge47570.egaug.es/ - house A
    # print(EgaugeInterface(mode=mode, endpoint=endpoint, username=user, password=password).processing_egauge_data())
    # do_every(4, collect_daily_data(), 1)
    generate_results()
