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
from utils.auth import require_auth, check_house_access
from utils.logging import get_logger
from utils.tsdb import get_tsdb_conn

logger = get_logger('analytics')
api_analytics = Blueprint('analytics', __name__)

@api_analytics.route('/list', methods=['POST'])
@require_auth()
@check_house_access()
def analytics_list():
    # Read all analytics from database
    data = request.json
    if 'house_id' not in data:
        return err_json('bad request')

    query_result = Analytics.query.filter_by(house_id=data['house_id']).all()
    ret = []
    for row in query_result:
        ret.append({
            'analytics_id': row.analytics_id,
            'name': row.name,
            'description': row.description,
            'formula': row.formula,
            'continuous_aggregation': row.continuous_aggregation
        })
    
    return jsonify({'status': 'ok', 'analytics': ret})

@api_analytics.route('/details', methods=['POST'])
@require_auth()
@check_house_access()
def analytics_details():
    # Read all analytics from database
    data = request.json
    if 'house_id' not in data:
        return err_json('bad request')
    if 'name' not in data:
        return err_json('bad request')

    row = Analytics.query.filter_by(house_id=data['house_id'], name=data['name']).first()
    if row is None:
        return err_json('analytics not found')

    ret = {
        'analytics_id': row.analytics_id,
        'name': row.name,
        'description': row.description,
        'formula': row.formula,
        'continuous_aggregation': row.continuous_aggregation
    }
    
    return jsonify({'status': 'ok', 'analytics': ret})

@api_analytics.route('/create', methods=['POST'])
@require_auth('admin')
@check_house_access()
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
    if 'continuous_aggregation' not in data:
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
    continuous_aggregation = data['continuous_aggregation']
    data = Analytics(
        house_id=house_id,
        name=data['name'],
        description=data['description'],
        formula=data['formula'],
        continuous_aggregation=continuous_aggregation
    )
    db.session.add(data)
    db.session.commit()
    db.session.refresh(data, attribute_names=['analytics_id'])

    # Create dependency in MySQL; create continuous aggregation in TimescaleDB
    if continuous_aggregation:
        logger.info('Creating continuous aggregations, analytics_id=%d, identifiers=%s' % (data.analytics_id, idents))
        for ident in idents:
            if not _create_continuous_aggregation(house_id, ident, data.analytics_id):
                logger.warn('Creation failed! Reverting')
                Analytics.query.filter_by(analytics_id=data.analytics_id).delete()
                db.session.commit()
                return err_json('error while creating continuous aggregation')

    return jsonify({'status': 'ok'})

@api_analytics.route('/update', methods=['POST'])
@require_auth('admin')
@check_house_access()
def analytics_update():
    data = request.json

    # Validate input
    if 'name' not in data:
        return err_json('bad request')
    if 'house_id' not in data:
        return err_json('bad request')
    if 'formula' in data:
        engine = AnalyticsEngine()
        try:
            engine.parse_expression(data['formula'])
        except Exception as e:
            return err_json('could not parse formula: %s' % e)
        idents = engine.collect_identifiers()
    
    house_id = int(data['house_id'])
    name = data['name']

    # Retrieve row
    row = Analytics.query.filter_by(house_id=house_id, name=name).first()
    if row is None:
        return err_json('analytics not found')

    orig_ca = row.continuous_aggregation
    orig_formula = row.formula
    
    engine = AnalyticsEngine()
    try:
        engine.parse_expression(orig_formula)
    except Exception as e:
        return err_json('could not parse formula: %s' % e)
    orig_idents = engine.collect_identifiers()

    # Save the data
    if 'description' in data:
        row.description = data['description']
    if 'formula' in data:
        row.formula = data['formula']
    if 'continuous_aggregation' in data:
        row.continuous_aggregation = data['continuous_aggregation']

    db.session.commit()

    # Determine if we need to update continuous aggregation
    update_ca_from_formula = False
    if 'continuous_aggregation' in data:
        if not orig_ca and data['continuous_aggregation']:
            # We need to create views
            effective_idents = idents if 'formula' in data else orig_idents
            for ident in effective_idents:
                _create_continuous_aggregation(house_id, ident, row.analytics_id)
        elif orig_ca and not data['continuous_aggregation']:
            # We need to remove views
            for ident in orig_idents:
                _delete_continuous_aggregation(house_id, ident, row.analytics_id)
        elif orig_ca and 'formula' in data:
            update_ca_from_formula = True
    elif 'formula' in data:
        update_ca_from_formula = True

    if update_ca_from_formula:
        orig_set = set(orig_idents)
        new_set = set(idents)
        to_be_created = new_set.difference(orig_set)
        to_be_deleted = orig_set.difference(new_set)
        for ident in to_be_created:
            _create_continuous_aggregation(house_id, ident, row.analytics_id)
        for ident in to_be_deleted:
            _delete_continuous_aggregation(house_id, ident, row.analytics_id)

    return jsonify({'status': 'ok'})

@api_analytics.route('/delete', methods=['POST'])
@require_auth(['admin'])
@check_house_access()
def analytics_delete():
    data = request.json

    # Validate input
    if 'house_id' not in data:
        return err_json('bad request')
    if 'name' not in data:
        return err_json('bad request')
    
    house_id = int(data['house_id'])
    name = data['name']

    # Check the analytics object exists
    row = Analytics.query.filter_by(house_id=house_id, name=name).first()
    if row is None:
        return err_json('analytics not found')

    # Collect identifiers and attempt to remove them
    if row.continuous_aggregation:
        engine = AnalyticsEngine()
        try:
            engine.parse_expression(row.formula)
        except Exception as e:
            return err_json('could not parse formula: %s' % e)
        idents = engine.collect_identifiers()
        for ident in idents:
            _delete_continuous_aggregation(house_id, ident, row.analytics_id)

    # Delete data from database
    db.session.delete(row)
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

def _delete_continuous_aggregation(house_id: int, identifier: str, analytics_id: int):
    # Remove relationship in MySQL
    dep = IdentifierDependency.query.filter_by(
        house_id=house_id,
        identifier=identifier,
        analytics_id=analytics_id
    ).first()
    if dep is None:
        return
    logger.info('Removing continuous aggregation: %r' % dep)
    db.session.delete(dep)
    db.session.commit()

    # Check if anyone else depends on the view
    view = IdentifierDependency.query.filter(
        IdentifierDependency.house_id == house_id,
        IdentifierDependency.identifier == identifier,
        IdentifierDependency.analytics_id != analytics_id).first()
    if view is not None:
        logger.info('The continuous aggregation is required by other analytics, will not remove from TimescaleDB.')
        return

    # Remove IdentifierView
    view = IdentifierView.query.filter_by(house_id=house_id, identifier=identifier).first()
    view_name = view.view_name
    logger.info('Dropping view %s' % view_name)
    db.session.delete(view)
    db.session.commit()

    # Remove continuous aggregation from TimescaleDB
    conn = get_tsdb_conn()
    prev_isolation_level = conn.isolation_level
    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    sql = 'DROP MATERIALIZED VIEW {}'.format(view_name)
    try:
        cur = conn.cursor()
        cur.execute(sql)
        cur.close()
        conn.commit()
    except Exception as e:
        logger.warn('Could not drop view: %s' % e)
    conn.set_isolation_level(prev_isolation_level)
    return

def _create_continuous_aggregation(house_id: int, identifier: str, analytics_id: int):
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
