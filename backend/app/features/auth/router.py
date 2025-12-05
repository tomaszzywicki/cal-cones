from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.dependencies import get_db, get_current_user_uid
from app.core.logger_setup import get_logger
from .schemas import UserCreate, UserResponse
from .service import create_user_account, get_user_account_by_uid
from .exceptions import UserAlreadyExistsException, UserDoesNotExistsException


logger = get_logger(__name__)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup/", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register_user(
    user_credential: UserCreate,
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    logger.debug(f"Signup attempt for UID: {user_credential.uid}")
    logger.debug(f"Current user UID from token: {current_user_uid}")
    try:
        user = create_user_account(db, user_credential)
    except UserAlreadyExistsException:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="User already exists")
    return user


@router.post("/signin/", response_model=UserResponse, status_code=status.HTTP_200_OK)
async def login_user(db: Session = Depends(get_db), current_user_uid=Depends(get_current_user_uid)):
    try:
        user = get_user_account_by_uid(db, current_user_uid)
    except UserDoesNotExistsException:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user


@router.post("/delete/")
async def delete_user_account(db: Session = Depends(get_db)):
    pass
