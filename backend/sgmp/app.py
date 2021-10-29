import decimal
import json
import os
import numpy as np
from datetime import datetime
from flask import Flask, jsonify, g
from flask_cors import CORS
from flask_migrate import Migrate

from routes.data import api_data
from routes.role import api_role
from routes.user import api_user
from routes.event import api_event
from routes.house import api_house
from routes.device import api_device
from routes.analytics import api_analytics

from models.shared import db

import models.analytics
import models.identifier_view
import models.identifier_dependency
import models.device
import models.house

from utils.tsdb import put_tsdb_conn
import utils.config as config

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_DATABASE_URI'] = config.DATABASE_URL
db.init_app(app)
migrate = Migrate(app, db)

class SGMPJsonEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return int(obj)
        if isinstance(obj, np.integer):
            return int(obj)
        if isinstance(obj, np.floating):
            return float(obj)
        if isinstance(obj, datetime):
            return int(obj.timestamp() * 1000)
        return super(SGMPJsonEncoder, self).default(obj)

app.json_encoder = SGMPJsonEncoder

app.register_blueprint(api_data, url_prefix='/api/data')
app.register_blueprint(api_role, url_prefix='/api/role')
app.register_blueprint(api_user, url_prefix='/api/user')
app.register_blueprint(api_event, url_prefix='/api/event')
app.register_blueprint(api_house, url_prefix='/api/house')
app.register_blueprint(api_device, url_prefix='/api/device')
app.register_blueprint(api_analytics, url_prefix='/api/analytics')

@app.teardown_appcontext
def close_conn(e):
    db = g.pop('tsdb', None)
    if db is not None:
        put_tsdb_conn(db)

@app.route('/api')
def health_check():
    return jsonify({
        'status': 'ok',
        'message': 'i\'m healthy'
    })

@app.errorhandler(404)
def page_not_found(_):
    return jsonify({
        'status': 'error',
        'message': 'not found'
    }), 404

@app.errorhandler(500)
def server_error(_):
    return jsonify({
        'status': 'error',
        'message': 'internal server error'
    }), 500

# Develop server
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', '5000')))