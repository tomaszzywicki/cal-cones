import firebase_admin
from firebase_admin import auth
from fastapi import HTTPException, status, Header, Depends
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
        if not firebase_admin._apps:
            logger.error("Firebase Admin SDK not initialized!")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Firebase not initialized",
            )

        decoded_token = auth.verify_id_token(
            token, check_revoked=True, clock_skew_seconds=60
        )

        logger.debug(f"Token verified successfully. UID: {decoded_token.get('uid')}")
        return decoded_token

    except auth.InvalidIdTokenError as e:
        logger.error(f"Invalid firebase token: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail=f"Invalid token: {str(e)}"
        )
    except Exception as e:
        logger.error(f"Error verifying firebase token: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error",
        )


def extract_token_from_header(authorization: str = Header(...)) -> str:
    """Extracts Bearer token from Authorization header"""
    if not authorization or not authorization.startswith("Bearer "):
        logger.warning("Authorization header missing or malformed")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header",
        )
    return authorization.split("Bearer ")[1]


def get_current_user_uid(token: str = Depends(extract_token_from_header)) -> str:
    """Gets current user uid from firebase token"""
    decoded_token = verify_firebase_token(token)
    return decoded_token.get("uid")
