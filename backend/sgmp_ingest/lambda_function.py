import psycopg2
import psycopg2.extras

pg_host = '54.241.73.105'
pg_user = 'postgres'
pg_pass = 'w2XeQwZSmExnGntNjsBteGJUfZkbimEc'
pg_database = 'sgmp'

sql = 'INSERT INTO data (timestamp, device_id, field, value_decimal, value_text) VALUES %s'
sql_house = 'INSERT INTO house_data (timestamp, house_id, device_name, field, value_decimal, value_text) VALUES %s'

# Function reference: https://stackoverflow.com/questions/6027558/flatten-nested-dictionaries-compressing-keys
def flatten(d, parent_key='') -> dict:
    items = []
    for k, v in d.items():
        new_key = parent_key + '.' + k if parent_key else k
        if isinstance(v, dict):
            items.extend(flatten(v, new_key).items())
        else:
            # Try cast to float
            try:
                v_float = float(v)
                items.append((new_key, v_float))
            except ValueError:
                items.append((new_key, str(v)))
    return dict(items)


def lambda_handler(event, context):
    # Connect to database
    conn = psycopg2.connect(
        host=pg_host,
        database=pg_database,
        user=pg_user,
        password=pg_pass)

    # Extract payload
    timestamp = float(event['timestamp']) / 1000
    device_id = event['device_id']
    device_name = event['device_name']
    client_id = event['client_id']
    house_id = int(client_id.split('_')[-1])

    fields = flatten(event['data'])

    data = []
    data_house = []

    for field, value in fields.items():
        if isinstance(value, float) or isinstance(value, int):
            data.append((timestamp, device_id, field, value, None))
            data_house.append((timestamp, house_id, device_name, field, value, None))
        else:
            data.append((timestamp, device_id, field, None, value))
            data_house.append((timestamp, house_id, device_name, field, None, value))

    cur = conn.cursor()
    psycopg2.extras.execute_values(cur, sql, data, template='(to_timestamp(%s), %s, %s, %s, %s)')
    psycopg2.extras.execute_values(cur, sql_house, data_house, template='(to_timestamp(%s), %s, %s, %s, %s, %s)')
    conn.commit()
    cur.close()
    
    return 'Inserted %d fields, device_id=%d, timestamp=%d' % (len(fields), event['device_id'], event['timestamp'])
