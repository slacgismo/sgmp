from fastapi import FastAPI
import uvicorn
import logging
import asyncpg
import os

log_config = uvicorn.config.LOGGING_CONFIG
log_config['formatters']['access']['fmt'] = '%(asctime)s - %(levelname)s - %(message)s'
log_config['formatters']['default']['fmt'] = '%(asctime)s - %(levelname)s - %(message)s'
logger = logging.getLogger('uvicorn.error')

app = FastAPI()

db = None

@app.on_event('startup')
async def startup_event():
    global db

    logger.info('Starting up SGMP Ingest Server.')

    tsdb_url = os.environ.get('TSDB_URL')
    if tsdb_url is None:
        raise Exception('Missing database connection info! Exiting.')

    db = await asyncpg.create_pool(dsn=tsdb_url)

@app.get('/')
def health_check():
    return {
        'status': 'ok',
        'message': 'i\'m healthy'
    }

if __name__ == '__main__':
    uvicorn.run(app)