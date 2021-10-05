import decimal
import json
from flask import Flask, jsonify
from flask_cors import CORS

from routes.data import api_data
from routes.role import api_role
from routes.user import api_user
from routes.device import api_device
from routes.analytics import api_analytics

from models.shared import db

app = Flask(__name__)
CORS(app)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///test.sqlite'
db.init_app(app)

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)

app.json_encoder = DecimalEncoder

app.register_blueprint(api_data, url_prefix='/api/data')
app.register_blueprint(api_role, url_prefix='/api/role')
app.register_blueprint(api_user, url_prefix='/api/user')
app.register_blueprint(api_device, url_prefix='/api/device')
app.register_blueprint(api_analytics, url_prefix='/api/analytics')

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