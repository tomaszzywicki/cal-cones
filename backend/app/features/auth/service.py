from sqlalchemy.orm import Session
from datetime import datetime, timezone

from app.models.user import User
from .schemas import UserCreate, UserResponse
from .exceptions import UserAlreadyExistsException


def create_user_account(db: Session, user_credential: UserCreate) -> UserResponse:
    """Creates a new user account in a database"""
    if get_user_account_by_uid(db, user_credential.uid) or get_user_account_by_email(
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


def delete_user_account():
    """Deletes user account from a database"""
    pass


def get_user_account_by_uid(db: Session, uid: str) -> User | None:
    return db.query(User).filter(User.uid == uid).first()


def get_user_account_by_email(db: Session, email: str) -> User | None:
    return db.query(User).filter(User.email == email).first()
