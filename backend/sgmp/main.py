from flask import Flask, jsonify

from routes.data import api_data
from routes.role import api_role
from routes.user import api_user
from routes.device import api_device

from models.shared import db

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///test.sqlite'
db.init_app(app)

app.register_blueprint(api_data, url_prefix='/api/data')
app.register_blueprint(api_role, url_prefix='/api/role')
app.register_blueprint(api_user, url_prefix='/api/user')
app.register_blueprint(api_device, url_prefix='/api/device')

@app.route('/api')
def health_check():
    return jsonify({
        'status': 'ok',
        'message': 'i\'m healthy'
    })
