from flask import g

import psycopg2
import psycopg2.pool
import boto3
import dns.resolver

import utils.config as config

from utils.logging import get_logger

logger = get_logger('tsdb')

def resolve_tsdb_host():
    if len(config.TSDB_HOST) > 0:
        logger.info('Using configured TSDB_HOST %s' % config.TSDB_HOST)
        return config.TSDB_HOST
    
    logger.info('Querying EC2 for Consul servers...')

    # Filter for running Consul servers
    tag_filter = [
        {
            'Name': 'tag:aws:autoscaling:groupName', 
            'Values': [(config.DEPLOYMENT_NAME + '_consul')]
        },
        {
            'Name': 'instance-state-name',
            'Values': ['running']
        }
    ]
    
    # Collect a list of Consul server IPs
    ec2 = boto3.client('ec2', region_name=config.AWS_REGION)
    consul_ip = []
    response = ec2.describe_instances(Filters=tag_filter)
    for r in response['Reservations']:
        for i in r['Instances']:
            consul_ip.append(i['NetworkInterfaces'][0]['PrivateIpAddress'])
    logger.info('Consul servers: %s' % (', '.join(consul_ip)))
    
    # Ask for TimescaleDB master IP
    resolver = dns.resolver.Resolver()
    resolver.nameservers = consul_ip
    resolver.port = 8600
    answer = resolver.query('master.tsdb.service.consul', 'A')
    pg_host = answer[0].to_text()
    logger.info('TimescaleDB master IP: %s' % pg_host)

    return pg_host

conn_pool = psycopg2.pool.SimpleConnectionPool(
    1, 16,
    host=resolve_tsdb_host(),
    user=config.TSDB_USER,
    password=config.TSDB_PASS,
    database=config.TSDB_DATABASE
)

def get_tsdb_conn():
    if 'tsdb' not in g:
        g.tsdb = conn_pool.getconn()
    return g.tsdb

def put_tsdb_conn(conn):
    conn_pool.putconn(conn)