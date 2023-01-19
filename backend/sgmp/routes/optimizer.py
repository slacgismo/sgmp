# TODO:
#   Add demand charges
#   Add solar forecast
#   Add EV control (need to fix PF API)
#   Add EV arrival/departure model
#   Add robust MPC
#   Add PID within the battery command
import pathlib
import pandas as pd
from flask import Blueprint, jsonify, request

from utils import config
from utils.auth import require_auth
from utils.functions import err_json

api_optimizer = Blueprint('optimizer', __name__)


@api_optimizer.route('/start', methods=['POST'])
@require_auth()
def start_optimizer():
    data = request.json
    house = data["house"]

    parent_path = pathlib.Path(__file__).parent.resolve().parent.resolve()
    path = str(parent_path) + '/optimizer/' + house + '_input.csv'
    df_egauge = pd.read_csv(path)
    if len(df_egauge) >= 1441:  # call optimization script when data is enough
        config.write_config('START_OPTIMIZER', 1)
    elif len(df_egauge) < 1441:  # input data is not enough
        return err_json('input data is not enough')

    return jsonify({
        'status': 'ok'
    })


@api_optimizer.route('/terminate', methods=['POST'])
@require_auth()
def terminate_optimizer():
    config.write_config('START_OPTIMIZER', 0)
    return jsonify({
        'status': 'ok'
    })


if __name__ == "__main__":
    user = 'gismolab'
    password = 'slacGISMO'
    url240 = 'https://egauge47573.egaug.es/cgi-bin/egauge'
    mode = 'web'
    endpoint = 'egauge47571.egaug.es/'  # house B
    # endpoint = egauge47570.egaug.es/ - house A
