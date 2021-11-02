import boto3
import psycopg2
import psycopg2.extras
import os
import json
import dns.resolver
import random

sql_house = 'INSERT INTO house_data (timestamp, house_id, device_name, field, value_decimal, value_text) VALUES %s'
sql_event = 'INSERT INTO events (timestamp, house_id, device_name, "type", "data") VALUES (to_timestamp(%s), %s, %s, %s, %s)'

secretsmanager = boto3.client('secretsmanager')
ec2 = boto3.client('ec2')

resource_prefix = os.environ['RESOURCE_PREFIX']

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

def read_pg_pass():
    response = secretsmanager.get_secret_value(SecretId=(resource_prefix + '_credentials'))
    
    secret = response['SecretString']
    secret = json.loads(secret)
    
    pg_pass = secret['tsdb_sgmp']
    return pg_pass
    
def read_pg_host():
    custom_filter = [
        {
            'Name': 'tag:aws:autoscaling:groupName', 
            'Values': [(resource_prefix + '_consul')]
        },
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]
    
    consul_ip = []
    response = ec2.describe_instances(Filters=custom_filter)
    for r in response['Reservations']:
        for i in r['Instances']:
            consul_ip.append(i['NetworkInterfaces'][0]['PrivateIpAddress'])
    
    resolver = dns.resolver.Resolver()
    resolver.nameservers = consul_ip
    resolver.port = 8600
    answer = resolver.query('master.tsdb.service.consul', 'A')
    pg_host = answer[0].to_text()
    return pg_host

def lambda_handler(event, context):
    pg_database = 'sgmp'
    pg_user = 'sgmp'
    pg_host = read_pg_host()
    pg_pass = read_pg_pass()
    
    print('Consul returned TimescaleDB master %s' % pg_host)

    # Connect to database
    conn = psycopg2.connect(
        host=pg_host,
        database=pg_database,
        user=pg_user,
        password=pg_pass)

    if 'topic' in event and event['topic'] == 'event':
        # Extract payload
        timestamp = float(event['timestamp']) / 1000
        device_name = event['device_name']
        client_id = event['client_id']
        house_id = int(client_id.split('_')[-1])
        type = event['data']['type']
        data = json.dumps(event['data']['data'])
        cur = conn.cursor()
        cur.execute(sql_event, (timestamp, house_id, device_name, type, data))
        conn.commit()
        cur.close()
        
        return 'Event %s, device_id=%d, timestamp=%d' % (type, event['device_id'], event['timestamp'])
        
    else:
        # Extract payload
        timestamp = float(event['timestamp']) / 1000
        device_name = event['device_name']
        client_id = event['client_id']
        house_id = int(client_id.split('_')[-1])

        fields = flatten(event['data'])

        data_house = []

        for field, value in fields.items():
            if isinstance(value, float) or isinstance(value, int):
                data_house.append((timestamp, house_id, device_name, field, value, None))
            else:
                data_house.append((timestamp, house_id, device_name, field, None, value))

        cur = conn.cursor()
        psycopg2.extras.execute_values(cur, sql_house, data_house, template='(to_timestamp(%s), %s, %s, %s, %s, %s)')
        conn.commit()
        cur.close()
        
        return 'Inserted %d fields, device_id=%d, timestamp=%d' % (len(fields), event['device_id'], event['timestamp'])
