import time
import pandas as pd
import numpy as np
import cvxpy as cvx
import pathlib
import AWSIoTPythonSDK.MQTTLib as AWSIoTPyMQTT
import json

import yaml

from utils import config
from utils.logging import get_logger

logger = get_logger('optimization_script')
IOT_ENDPOINT = "ahj7dwf3rk9hf.iot.us-west-1.amazonaws.com"
IOT_CLIENT_ID = "gismolab_sgmp_backend"
IOT_CERT_PATH = "/Users/xyc/Documents/XYC/master/courses/practicum/sgmp/backend/sgmp/iot_certs/device.pem"
IOT_KEY_PATH = "/Users/xyc/Documents/XYC/master/courses/practicum/sgmp/backend/sgmp/iot_certs/private.pem.key"
IOT_ROOT_PATH = "/Users/xyc/Documents/XYC/master/courses/practicum/sgmp/backend/sgmp/iot_certs/AmazonRootCA1.pem"
TOPIC_CONTROL_SONNEN = "gismolab_sgmp_write/"


def generate_results():
    parent_path = pathlib.Path(__file__).parent.resolve().parent.resolve()
    path = str(parent_path) + '/optimizer/houseB_input.csv'
    df_egauge = pd.read_csv(path)

    ret_json = {
        "DeviceID": "1", "DeviceInformation":
            [
                {"resource": "solar", "payload": "payload"},
                {"resource": "battery",
                 "payload": {"mode": "manual", "power": [-1.3455643e-10, 5.3454372e-9, -7.1234567e-11]}},
                {"resource": "ev", "payload": "payload"}
            ]
    }

    # delete the data before last 24 hours
    num = len(df_egauge) - 1441
    df_egauge.drop(df_egauge.head(num).index, inplace=True)
    df_egauge.to_csv(path, index=False)

    df_egauge['Timestamp'] = pd.to_datetime(df_egauge['Date & Time'], errors='coerce')
    egauge = df_egauge.set_index('Timestamp')
    egauge.drop(columns='Date & Time', inplace=True)
    egauge.sort_index(inplace=True)

    # data = egauge[1:]

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
    solar.fillna(method='ffill', inplace=True)
    solar = solar * (-1.0)
    # Battery:
    battery.fillna(method='ffill', inplace=True)
    battery = battery * (-1)
    # Grid:
    grid.fillna(method='ffill', inplace=True)
    grid = grid * (-1)
    # EV:
    ev.fillna(method='ffill', inplace=True)
    ev = ev * (-1)
    # Load:
    load.fillna(method='ffill', inplace=True)
    load = load * (-1)

    net_load_original = solar[0:1440] + battery[0:1440] + ev[0:1440]

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

    objective = energy_charges.reshape((1, energy_charges.size)) @ cvx.reshape(cvx.pos(P.values + c), (T, 1))
    # objective = energy_charges.reshape((1,energy_charges.size)) @ cvx.reshape(cvx.pos(P.values + c - d), (T, 1))
    objective += backfeed_charges.reshape((1, backfeed_charges.size)) @ cvx.reshape(cvx.neg(P.values + c), (T, 1))

    try:
        min = cvx.Minimize(objective)
        prob = cvx.Problem(min, constraints=constraints)
        prob.solve(solver=cvx.ECOS)
    except Exception as e:
        logger.warning("problem solve failed: ", e)

    result = np.around(c.value, 2)
    ret_json["DeviceInformation"][0]["payload"] = list(solar.values)
    ret_json["DeviceInformation"][1]["payload"]["power"] = result[0]
    ret_json["DeviceInformation"][2]["payload"] = list(ev.values)

    try:
        publishPowerValues(ret_json)
    except Exception as e:
        logger.warning("publish power values failed")


# Publish output of the optimizer algorithm to an MQTT control topic for specific house
def publishPowerValues(publishMessage):
    # initialize client:
    myAWSIoTMQTTClient = AWSIoTPyMQTT.AWSIoTMQTTClient(IOT_CLIENT_ID)
    myAWSIoTMQTTClient.configureEndpoint(IOT_ENDPOINT, 8883)
    myAWSIoTMQTTClient.configureCredentials(IOT_ROOT_PATH, IOT_KEY_PATH, IOT_CERT_PATH)

    mqtt_connect = False
    while not (mqtt_connect):
        mqtt_connect = myAWSIoTMQTTClient.connect()
        print("Connected to AWS IoT client: ", mqtt_connect)

    myAWSIoTMQTTClient.publish(TOPIC_CONTROL_SONNEN + publishMessage["DeviceID"] + "/battery",
                               json.dumps(publishMessage), QoS=1)


def do_every(period, f):
    def g_tick():
        t = time.time()
        while True:
            t += period
            yield max(t - time.time(), 0)

    g = g_tick()
    while True:
        print(config.get_new_config('START_OPTIMIZER'))
        if config.get_new_config('START_OPTIMIZER') == 1:
            f()
            time.sleep(next(g))
        else:
            time.sleep(5)
            g = g_tick()
            # config.write_config('START_OPTIMIZER',1)


# def test_get(key):
#     with open('/Users/xyc/Documents/XYC/master/courses/practicum/sgmp/backend/sgmp/config.yaml', 'r') as f:
#         config1 = yaml.load(f, Loader=yaml.SafeLoader)
#         f.close()
#         return config1[key]


if __name__ == "__main__":
    user = 'gismolab'
    password = 'slacGISMO'
    url240 = 'https://egauge47573.egaug.es/cgi-bin/egauge'
    mode = 'web'
    endpoint = 'egauge47571.egaug.es/'  # house B
    # endpoint = egauge47570.egaug.es/ - house A
    do_every(5 * 1, generate_results)
