import os
import firebase_admin
from firebase_admin import credentials, auth

from app.core.logger_setup import get_logger
from app.config import FIREBASE_KEY_PATH

logger = get_logger(__name__)


def initialize_firebase():
    """Init Firebase Admin SDK"""
    if not firebase_admin._apps:
        if not os.path.exists(FIREBASE_KEY_PATH):
            logger.error(
                f"Firebase admin SDK json file not found at {FIREBASE_KEY_PATH}"
            )
            raise FileNotFoundError(
                f"Firebase admin SDK json file not found at {FIREBASE_KEY_PATH}"
            )
        try:
            credential = credentials.Certificate(FIREBASE_KEY_PATH)
            firebase_admin.initialize_app(credential)
            logger.debug("Firebase Admin SDK has been successfully initialized")
        except Exception as e:
            logger.error(f"Failed to initialize Firebase: {str(e)}")
            raise RuntimeError(f"Error when initializing Firebase: {e}")
    else:
        logger.debug("Firebase Admin SDK is already initialized.")
