from flask import g

import psycopg2
import psycopg2.pool

import utils.config as config

conn_pool = psycopg2.pool.SimpleConnectionPool(
    1, 16,
    host=config.TSDB_HOST,
    user=config.TSDB_USER,
    password=config.TSDB_PASS,
    database=config.TSDB_DATABASE
)

def get_tsdb_conn():
    if 'tsdb' not in g:
        g.db = conn_pool.getconn()
    return g.db