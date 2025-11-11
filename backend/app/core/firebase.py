import firebase_admin
from firebase_admin import credentials

from app.config import FIREBASE_KEY_PATH


def initialize_firebase():
    """Init Firebase Admin SDK"""
    # if not firebase_admin._apps:
    #     try:
    #         credential = credentials.Certificate(FIREBASE_KEY_PATH)
    #         firebase_admin.initialize_app(credential)
    #     except Exception as e:
