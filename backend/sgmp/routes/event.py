from flask import Blueprint, jsonify, request

from utils.functions import err_json
from utils.auth import require_auth
from utils.tsdb import get_tsdb_conn
import utils.config as config

api_event = Blueprint('event', __name__)

@api_event.route('/read', methods=['POST'])
@require_auth()
def event_read():
    data = request.json

    # Validate input
    if 'house_id' not in data:
        return err_json('bad request')
    if 'start_time' not in data:
        return err_json('bad request')
    if 'end_time' not in data:
        return err_json('bad request')

    house_id = int(data['house_id'])
    start_time = float(data['start_time']) / 1000
    end_time = float(data['end_time']) / 1000
    # Support for different filtering combinations
    type = None
    device_name = None
    if 'type' in data:
        if isinstance(data['type'], list):
            type = data['type']
        elif isinstance(data['type'], str):
            type = [data['type']]
        else:
            return err_json('bad request')
    if 'device_name' in data:
        if isinstance(data['device_name'], list):
            device_name = data['device_name']
        elif isinstance(data['device_name'], str):
            device_name = [data['device_name']]
        else:
            return err_json('bad request')

    # Get DB connection
    conn = get_tsdb_conn()
    cursor = conn.cursor()

    # Construct and execute query
    sql_prefix = 'SELECT timestamp, device_name, type, data FROM events WHERE '
    sql_postfix = ' ORDER BY timestamp DESC'
    if type is None and device_name is None:
        sql = sql_prefix + 'timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id=%s' + sql_postfix
        cursor.execute(sql, (start_time, end_time, house_id))
    elif type is None and device_name is not None:
        sql = sql_prefix + 'timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id=%s AND device_name IN %s' + sql_postfix
        cursor.execute(sql, (start_time, end_time, house_id, tuple(device_name)))
    elif type is not None and device_name is None:
        sql = sql_prefix + 'timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id=%s AND type IN %s' + sql_postfix
        cursor.execute(sql, (start_time, end_time, house_id, tuple(type)))
    else:
        sql = sql_prefix + 'timestamp BETWEEN to_timestamp(%s) AND to_timestamp(%s) AND house_id=%s AND device_name IN %s AND type IN %s' + sql_postfix
        cursor.execute(sql, (start_time, end_time, house_id, tuple(device_name), tuple(type)))

    # Fetch results
    rows = cursor.fetchall()
    cursor.close()

    result = []
    for row in rows:
        result.append({
            'timestamp': int(row[0].timestamp() * 1000),
            'device_name': row[1],
            'type': row[2],
            'data': row[3]
        })

    # Return results
    return jsonify({
        'status': 'ok',
        'events': result
    })