import logging
from fastapi import FastAPI, Depends, status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from app.core.logger_setup import get_logger
from app.features.auth.router import router as auth_router
from app.features.user.router import router as user_router
from app.core.firebase import initialize_firebase
from app.core.dependencies import verify_firebase_token, get_current_user_uid

logger = get_logger(__name__, logging.DEBUG)

app = FastAPI(title="CalCones API", description="API for CalCones app", version="1.0.0")

app.include_router(auth_router)
app.include_router(user_router)

initialize_firebase()


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request, exc):
    logger.error(f"Validation error: {exc.errors()}")
    logger.error(f"Request body: {await request.body()}")
    return JSONResponse(status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, content={"detail": exc.errors()})


@app.get("/")
async def read_root():
    return {"message": "Hello root"}


@app.get("/test/")
async def test():
    logger.error(f"Test error")
    logger.info("Test info")
    logger.critical("test critical")
    return {"test": "test"}
