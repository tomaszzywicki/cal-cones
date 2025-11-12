import logging
from fastapi import FastAPI

from app.core.logger_setup import get_logger
from app.features.auth.router import router as auth_router
from app.core.firebase import initialize_firebase

logger = get_logger(__name__, logging.DEBUG)

app = FastAPI(title="CalCones API", description="API for CalCones app", version="1.0.0")

app.include_router(auth_router)

initialize_firebase()


@app.get("/")
async def read_root():
    return {"message": "Hello root"}


@app.get("/test/")
async def test():
    logger.error(f"Test error")
    logger.info("Test info")
    logger.critical("test critical")
    return {"test": "test"}

