from fastapi import APIRouter, Depends, HTTPException, status
from requests import get

from app.core.logger_setup import get_logger
from backend.app.core.dependencies import get_current_user_uid, get_db
from backend.app.features.user.schemas import UserOnboardingCreate

logger = get_logger(__name__)

router = APIRouter(prefix="/user")


@router.post("/onboarding/create", status_code=status.HTTP_201_CREATED)
def create_onboarding_data(
    onboarding_data: UserOnboardingCreate,
    db=Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    pass
