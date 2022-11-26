# TODO:
#   Add demand charges
#   Add solar forecast
#   Add EV control (need to fix PF API)
#   Add EV arrival/departure model
#   Add robust MPC
#   Add PID within the battery command
from flask import Blueprint, jsonify
from utils.auth import require_auth
import time
import pandas as pd
import numpy as np
import cvxpy as cvx
import pathlib
import threading

from utils.functions import err_json

api_optimizer = Blueprint('optimizer', __name__)

STOP = False
thread = None


@api_optimizer.route('/start', methods=['POST'])
@require_auth()
def start_optimizer():
    status = generate_results()
    if not status:  # the input data is not enough
        return err_json('input data is not enough')

    global thread
    thread = threading.Thread(target=main_optimizer, name='optimizer_thread')
    thread.start()
    return jsonify({
        'status': 'ok'
    })


@api_optimizer.route('/terminate', methods=['POST'])
@require_auth()
def terminate_optimizer():
    global STOP
    STOP = True

    thread.join()
    return jsonify({
        'status': 'ok'
    })


def main_optimizer():
    do_every(5 * 60, generate_results())


def generate_results():
    parent_path = pathlib.Path(__file__).parent.resolve().parent.resolve()
    path = str(parent_path) + '/optimizer/houseB_input.csv'
    df_egauge = pd.read_csv(path)

    if len(df_egauge) > 1441:  # delete the data before last 24 hours
        num = len(df_egauge) - 1441
        df_egauge.drop(df_egauge.head(num).index, inplace=True)
        df_egauge.to_csv(path, index=False)
    elif len(df_egauge) < 1441:  # input data is not enough
        return False

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

    min = cvx.Minimize(objective)
    prob = cvx.Problem(min, constraints=constraints)
    prob.solve(solver=cvx.ECOS)

    result = np.around(c.value, 2)
    print(result)
    return True


def do_every(period, f):
    def g_tick():
        t = time.time()
        while True:
            t += period
            yield max(t - time.time(), 0)

    g = g_tick()
    while True:
        time.sleep(next(g))
        f()
        if STOP:
            break


# test the optimizer
if __name__ == "__main__":
    user = 'gismolab'
    password = 'slacGISMO'
    url240 = 'https://egauge47573.egaug.es/cgi-bin/egauge'
    mode = 'web'
    endpoint = 'egauge47571.egaug.es/'  # house B
    # endpoint = egauge47570.egaug.es/ - house A

    # generate_results()
