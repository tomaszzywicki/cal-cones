from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db
from app.core.logger_setup import get_logger
from .schemas import UserCreate, UserResponse
from .service import create_user_account
from .exceptions import UserAlreadyExistsException


logger = get_logger(__name__)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(user_credential: UserCreate, db: Session = Depends(get_db)):
    try:
        user = create_user_account(db, user_credential)
    except UserAlreadyExistsException:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT, detail="User already exists"
        )
    return user


@router.post("/delete/")
async def delete_user_account(db: Session = Depends(get_db)):
    pass
