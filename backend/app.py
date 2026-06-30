from flask import Flask, jsonify
from flask_cors import CORS
from db import init_db_pool, close_pool

from routes.auth import auth_bp
from routes.complaints import complaints_bp
from routes.resolutions import resolutions_bp
from routes.feedback import feedback_bp
from routes.departments import departments_bp
from routes.wards import wards_bp
from routes.analytics import analytics_bp

app = Flask(__name__)
app.config.from_pyfile('config.py')

# Enable CORS for frontend requests
CORS(app)

# Register Blueprints
app.register_blueprint(auth_bp, url_prefix='/api')
app.register_blueprint(complaints_bp, url_prefix='/api/complaints')
app.register_blueprint(resolutions_bp, url_prefix='/api/resolutions')
app.register_blueprint(feedback_bp, url_prefix='/api/feedback')
app.register_blueprint(departments_bp, url_prefix='/api/departments')
app.register_blueprint(wards_bp, url_prefix='/api/wards')
app.register_blueprint(analytics_bp, url_prefix='/api/analytics')

@app.before_first_request if hasattr(app, 'before_first_request') else app.before_request
def initialize_pool():
    # Only init pool on the very first request (workaround for Flask 3.x removing before_first_request)
    if not hasattr(app, 'pool_initialized'):
        init_db_pool()
        app.pool_initialized = True

@app.teardown_appcontext
def shutdown_session(exception=None):
    # Depending on how the pool is managed, normally oracledb pool is kept alive for the app lifecycle
    pass

@app.errorhandler(500)
def internal_error(e):
    return jsonify({"success": False, "error": "Internal Server Error"}), 500

@app.errorhandler(404)
def not_found(e):
    return jsonify({"success": False, "error": "Not Found"}), 404

if __name__ == '__main__':
    # Initialize DB Pool before app run
    init_db_pool()
    try:
        app.run(host='0.0.0.0', port=5000, debug=True)
    finally:
        close_pool()
