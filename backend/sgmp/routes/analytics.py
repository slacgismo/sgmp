from flask import Blueprint, jsonify, request
import random
import string

import psycopg2

from models.analytics import Analytics
from models.identifier_dependency import IdentifierDependency
from models.identifier_view import IdentifierView
from models.shared import db
from utils.analytics_engine import AnalyticsEngine

from utils.functions import err_json
from utils.auth import require_auth
from utils.logging import get_logger
from utils.tsdb import get_tsdb_conn

logger = get_logger('analytics')
api_analytics = Blueprint('analytics', __name__)

@api_analytics.route('/list', methods=['GET'])
@require_auth()
def analytics_list():
    # Read all analytics from database
    query_result = Analytics.query.all()
    ret = []
    for row in query_result:
        ret.append({
            'analytics_id': row.analytics_id,
            'name': row.name,
            'description': row.description,
            'formula': row.formula
        })
    
    return jsonify({'status': 'ok', 'analytics': ret})

@api_analytics.route('/create', methods=['POST'])
@require_auth('admin')
def analytics_create():
    data = request.json

    # Validate input
    if 'name' not in data:
        return err_json('bad request')
    if 'house_id' not in data:
        return err_json('bad request')
    if 'description' not in data:
        return err_json('bad request')
    if 'formula' not in data:
        return err_json('bad request')

    house_id = int(data['house_id'])

    # Check name does not exist
    count = Analytics.query.filter_by(house_id=house_id, name=data['name']).count()
    if count > 0:
        return err_json('analytics exists')

    # Extract identifiers from formula
    engine = AnalyticsEngine()
    try:
        engine.parse_expression(data['formula'])
    except Exception as e:
        return err_json('could not parse formula: %s' % e)
    idents = engine.collect_identifiers()

    # Save the data
    data = Analytics(
        house_id=house_id,
        name=data['name'],
        description=data['description'],
        formula=data['formula']
    )
    db.session.add(data)
    db.session.commit()
    db.session.refresh(data, attribute_names=['analytics_id'])

    # Create dependency in MySQL; create continuous aggregation in TimescaleDB
    logger.info('Creating continuous aggregations, analytics_id=%d, identifiers=%s' % (data.analytics_id, idents))
    for ident in idents:
        if not _create_identifier_dependency(house_id, ident, data.analytics_id):
            logger.warn('Creation failed! Reverting')
            Analytics.query.filter_by(analytics_id=data.analytics_id).delete()
            db.session.commit()
            return err_json('error while creating continuous aggregation')

    return jsonify({'status': 'ok'})

@api_analytics.route('/update', methods=['POST'])
@require_auth('admin')
def analytics_update():
    data = request.json

    # Validate input
    if 'analytics_id' not in data:
        return err_json('bad request')
    if 'description' not in data:
        return err_json('bad request')
    if 'formula' not in data:
        return err_json('bad request')

    # Retrieve row
    row = Analytics.query.filter_by(analytics_id=int(data['analytics_id'])).first()
    if row is None:
        return err_json('analytics not found')

    # Save the data
    row.description = data['description']
    row.formula = data['formula']
    db.session.commit()

    return jsonify({'status': 'ok'})

@api_analytics.route('/delete', methods=['POST'])
@require_auth(['admin'])
def analytics_delete():
    data = request.json

    # Validate input
    if 'analytics_id' not in data:
        return err_json('bad request')
    analytics_id = int(data['analytics_id'])

    # Delete data from database
    Analytics.query.filter_by(analytics_id=analytics_id).delete()
    db.session.commit()

    return jsonify({'status': 'ok'})

def _view_name(house_id: int):
    view_exists = True
    view_name = ''
    while view_exists:
        view_name = 'house_%d_%s' % (house_id, ''.join(random.choice(string.ascii_lowercase) for _ in range(6)))
        view = IdentifierView.query.filter_by(house_id=house_id, view_name=view_name).first()
        if view is None:
            view_exists = False
    return view_name


def _create_identifier_dependency(house_id: int, identifier: str, analytics_id: int):
    # Create relationship in MySQL
    dep = IdentifierDependency(
        house_id=house_id,
        identifier=identifier,
        analytics_id=analytics_id
    )
    db.session.add(dep)
    db.session.commit()

    # Check if continuous aggregation exists
    view = IdentifierView.query.filter_by(house_id=house_id, identifier=identifier).first()
    if view is not None:
        logger.info('Continuous aggregation for %s exists (%s), skipping.' % (identifier, view.view_name))
        return True

    # Create IdentifierView
    view_name = _view_name(house_id)
    view = IdentifierView(house_id=house_id, identifier=identifier, view_name=view_name)
    db.session.add(view)
    db.session.commit()

    # Create continuous aggregation in TimescaleDB
    device_name = identifier.split('.')[0]
    field = '.'.join(identifier.split('.')[1:])
    logger.info('Creating %s for device %s, field %s' % (view_name, device_name, field))
    sql = '''
        CREATE MATERIALIZED VIEW {}
            WITH (timescaledb.continuous) AS
                SELECT time_bucket('1 hour', timestamp) AS time,
                    AVG(value_decimal) AS average
                FROM house_data WHERE house_id = %s
                    AND device_name = %s
                    AND field = %s
                GROUP BY time
    '''.format(view_name)
    conn = get_tsdb_conn()
    prev_isolation_level = conn.isolation_level
    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    try:
        cur = conn.cursor()
        cur.execute(sql, (house_id, device_name, field))
        cur.close()
        conn.commit()
    except Exception as e:
        logger.warn('Could not create %s: %s' % (view_name, e))
        conn.set_isolation_level(prev_isolation_level)
        IdentifierView.query.filter_by(house_id=house_id, identifier=identifier).delete()
        IdentifierDependency.query.filter_by(house_id=house_id, identifier=identifier, analytics_id=analytics_id).delete()
        db.session.commit()
        return False

    logger.info('Creating continuous aggregate policy for %s' % view_name)
    sql = '''
        SELECT add_continuous_aggregate_policy('{}',
            start_offset => NULL,
            end_offset => INTERVAL '1 hour',
            schedule_interval => INTERVAL '1 hour'
        )
    '''.format(view_name)
    try:
        cur = conn.cursor()
        cur.execute(sql)
        cur.close()
        conn.commit()
    except Exception as e:
        conn.set_isolation_level(prev_isolation_level)
        logger.warn('Could not create policy for %s: %s' % (view_name, e))

    conn.set_isolation_level(prev_isolation_level)
    return True