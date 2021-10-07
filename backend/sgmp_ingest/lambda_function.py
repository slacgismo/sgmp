import json
import psycopg2

pg_host = '54.215.115.115'
pg_user = 'postgres'
pg_pass = 'w2XeQwZSmExnGntNjsBteGJUfZkbimEc'
pg_database = 'sgmp'

sql = 'INSERT INTO data (timestamp, device_id, data) VALUES (to_timestamp(%s), %s, %s)'

def lambda_handler(event, context):
    conn = psycopg2.connect(
        host=pg_host,
        database=pg_database,
        user=pg_user,
        password=pg_pass)
    cur = conn.cursor()
    cur.execute(sql,
        (float(event['timestamp']) / 1000, event['device_id'], json.dumps(event['data'])))
    conn.commit()
    cur.close()
    return 'Insert successful, device_id=%d, timestamp=%d' % (event['device_id'], event['timestamp'])
