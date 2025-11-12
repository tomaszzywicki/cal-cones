from firebase_admin import auth
from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.core.logger_setup import get_logger
from app.core.database import SessionLocal

logger = get_logger(__name__)


def get_db():
    """"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def verify_firebase_token(token: str):
    """Verifies the token provided by the firebase"""
    try:
        decoded_token = auth.verify_id_token(
            token, check_revoked=True, clock_skew_seconds=10
        )
        print(f"Test token: {decoded_token}")
        return decoded_token
    except auth.InvalidIdTokenError:
        logger.error(f"Invalid firebase token received: {token}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
        )
    except Exception as e:
        logger.error(f"Error veryfing firebase token: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error",
        )
