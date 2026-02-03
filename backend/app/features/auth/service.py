from sqlalchemy.orm import Session
from datetime import datetime, timezone

from app.models.user import User
from .schemas import UserCreate, UserResponse
from .exceptions import UserAlreadyExistsException, UserDoesNotExistsException
from app.core.logger_setup import get_logger

logger = get_logger(__name__)


def create_user_account(db: Session, user_credential: UserCreate) -> UserResponse:
    """Creates a new user account in a database"""
    if _get_user_account_by_uid(db, user_credential.uid) or _get_user_account_by_email(
        db, user_credential.email
    ):
        raise UserAlreadyExistsException("User already exists")

    db_user = User(
        uid=user_credential.uid,
        email=user_credential.email,
        created_at=datetime.now(tz=timezone.utc),
        last_modified_at=datetime.now(tz=timezone.utc),
        setup_completed=False,
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return UserResponse.model_validate(db_user)


def delete_user_account(db: Session, uid: str) -> UserResponse:
    """
    Deletes user account from a database
    based on a uid string
    """
    db_user = _get_user_account_by_uid(db, uid)
    if not db_user:
        logger.error(f"Error deleting user account: User with uid: {uid} does not exist.")
        raise UserDoesNotExistsException("User does not exist")

    db.delete(db_user)
    db.commit()
    return UserResponse.model_validate(db_user)


def get_user_account_by_uid(db: Session, uid: str) -> UserResponse:
    db_user = db.query(User).filter(User.uid == uid).first()
    if not db_user:
        logger.error(f"User with uid: {uid} does not exist")
        raise UserDoesNotExistsException("User does not exist")
    return UserResponse.model_validate(db_user)


def _get_user_account_by_uid(db: Session, uid: str) -> User | None:
    db_user = db.query(User).filter(User.uid == uid).first()
    return db_user


def _get_user_account_by_email(db: Session, email: str) -> User | None:
    return db.query(User).filter(User.email == email).first()
