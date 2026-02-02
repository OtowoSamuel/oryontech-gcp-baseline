"""
OryonTech Sample Application
Demonstrates Cloud Run connectivity to Cloud SQL via private networking
"""

import os
import logging
from datetime import datetime
from flask import Flask, jsonify, request
import sqlalchemy
from google.cloud.sql.connector import Connector
import pg8000

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Configuration from environment variables (injected from Secret Manager)
INSTANCE_CONNECTION_NAME = os.environ.get('INSTANCE_CONNECTION_NAME')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = os.environ.get('DB_NAME')
OPENAI_API_KEY = os.environ.get('OPENAI_API_KEY')
ENVIRONMENT = os.environ.get('ENVIRONMENT', 'unknown')

# Global database connection pool
db_pool = None


def init_connection_pool() -> sqlalchemy.engine.Engine:
    """Initialize database connection pool using Cloud SQL Connector"""
    
    if not all([INSTANCE_CONNECTION_NAME, DB_USER, DB_PASSWORD, DB_NAME]):
        logger.error("Missing required database configuration")
        raise ValueError("Database configuration incomplete")
    
    logger.info(f"Initializing connection to: {INSTANCE_CONNECTION_NAME}")
    
    # Initialize Cloud SQL Connector
    connector = Connector()
    
    def getconn() -> pg8000.dbapi.Connection:
        """Create database connection using private IP"""
        conn = connector.connect(
            INSTANCE_CONNECTION_NAME,
            "pg8000",
            user=DB_USER,
            password=DB_PASSWORD,
            db=DB_NAME,
            ip_type="PRIVATE"  # Use private IP through VPC connector
        )
        return conn
    
    # Create connection pool
    pool = sqlalchemy.create_engine(
        "postgresql+pg8000://",
        creator=getconn,
        pool_size=5,
        max_overflow=2,
        pool_timeout=30,
        pool_recycle=1800,
    )
    
    logger.info("Database connection pool initialized")
    return pool


def init_database():
    """Initialize database schema"""
    global db_pool
    
    try:
        with db_pool.connect() as conn:
            # Create sample table
            conn.execute(sqlalchemy.text("""
                CREATE TABLE IF NOT EXISTS health_checks (
                    id SERIAL PRIMARY KEY,
                    timestamp TIMESTAMP NOT NULL,
                    status VARCHAR(50) NOT NULL,
                    environment VARCHAR(50)
                )
            """))
            conn.commit()
            logger.info("Database schema initialized")
    except Exception as e:
        logger.error(f"Failed to initialize database: {e}")


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'environment': ENVIRONMENT,
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/health/db', methods=['GET'])
def database_health():
    """Database connectivity health check"""
    global db_pool
    
    try:
        with db_pool.connect() as conn:
            # Test database connection
            result = conn.execute(sqlalchemy.text("SELECT 1 as test"))
            row = result.fetchone()
            
            # Log health check
            conn.execute(
                sqlalchemy.text("""
                    INSERT INTO health_checks (timestamp, status, environment)
                    VALUES (:timestamp, :status, :environment)
                """),
                {
                    "timestamp": datetime.utcnow(),
                    "status": "healthy",
                    "environment": ENVIRONMENT
                }
            )
            conn.commit()
            
            return jsonify({
                'status': 'healthy',
                'database': 'connected',
                'connection_name': INSTANCE_CONNECTION_NAME,
                'environment': ENVIRONMENT,
                'test_query': bool(row[0] == 1),
                'timestamp': datetime.utcnow().isoformat()
            }), 200
            
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        return jsonify({
            'status': 'unhealthy',
            'database': 'disconnected',
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 503


@app.route('/', methods=['GET'])
def index():
    """Root endpoint"""
    return jsonify({
        'service': 'OryonTech Agent Platform',
        'environment': ENVIRONMENT,
        'version': '1.0.0',
        'endpoints': {
            'health': '/health',
            'database_health': '/health/db',
            'info': '/info',
            'metrics': '/metrics'
        },
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/info', methods=['GET'])
def info():
    """Service information endpoint"""
    return jsonify({
        'environment': ENVIRONMENT,
        'database_configured': bool(INSTANCE_CONNECTION_NAME),
        'openai_configured': bool(OPENAI_API_KEY and OPENAI_API_KEY != 'mock-key'),
        'connection_info': {
            'instance': INSTANCE_CONNECTION_NAME,
            'database': DB_NAME,
            'user': DB_USER
        },
        'timestamp': datetime.utcnow().isoformat()
    }), 200


@app.route('/metrics', methods=['GET'])
def metrics():
    """Simple metrics endpoint"""
    global db_pool
    
    try:
        with db_pool.connect() as conn:
            # Get recent health checks count
            result = conn.execute(sqlalchemy.text("""
                SELECT COUNT(*) as total,
                       MAX(timestamp) as last_check
                FROM health_checks
                WHERE timestamp > NOW() - INTERVAL '1 hour'
            """))
            row = result.fetchone()
            
            return jsonify({
                'health_checks_last_hour': row[0] if row else 0,
                'last_check': row[1].isoformat() if row and row[1] else None,
                'timestamp': datetime.utcnow().isoformat()
            }), 200
            
    except Exception as e:
        logger.error(f"Failed to fetch metrics: {e}")
        return jsonify({
            'error': 'Failed to fetch metrics',
            'timestamp': datetime.utcnow().isoformat()
        }), 500


@app.errorhandler(404)
def not_found(error):
    """Handle 404 errors"""
    return jsonify({
        'error': 'Not found',
        'path': request.path,
        'timestamp': datetime.utcnow().isoformat()
    }), 404


@app.errorhandler(500)
def internal_error(error):
    """Handle 500 errors"""
    logger.error(f"Internal error: {error}")
    return jsonify({
        'error': 'Internal server error',
        'timestamp': datetime.utcnow().isoformat()
    }), 500


if __name__ == '__main__':
    # Initialize database connection pool
    try:
        db_pool = init_connection_pool()
        init_database()
    except Exception as e:
        logger.error(f"Failed to initialize database: {e}")
        # Continue anyway for health endpoint
    
    # Run with gunicorn in production, flask dev server for local
    port = int(os.environ.get('PORT', 8080))
    
    if os.environ.get('FLASK_ENV') == 'development':
        app.run(host='0.0.0.0', port=port, debug=True)
    else:
        # Production: use gunicorn
        from gunicorn.app.base import BaseApplication
        
        class StandaloneApplication(BaseApplication):
            def __init__(self, app, options=None):
                self.options = options or {}
                self.application = app
                super().__init__()
            
            def load_config(self):
                for key, value in self.options.items():
                    self.cfg.set(key.lower(), value)
            
            def load(self):
                return self.application
        
        options = {
            'bind': f'0.0.0.0:{port}',
            'workers': 2,
            'threads': 4,
            'worker_class': 'gthread',
            'timeout': 120,
            'accesslog': '-',
            'errorlog': '-',
            'loglevel': 'info'
        }
        
        logger.info(f"Starting gunicorn server on port {port}")
        StandaloneApplication(app, options).run()
