from fastapi import APIRouter, Depends, HTTPException, status
from requests import get

from app.core.logger_setup import get_logger
from app.core.dependencies import get_current_user_uid, get_db
from app.features.user.schemas import UserOnboardingCreate
from app.features.user.service import complete_user_onboarding
from app.features.auth.service import get_user_account_by_uid


logger = get_logger(__name__)

router = APIRouter(prefix="/user")


@router.post("/onboarding/create/", status_code=status.HTTP_201_CREATED)
async def create_onboarding_data(
    onboarding_data: UserOnboardingCreate,
    db=Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    """Complete user onboarding - setup profile and create first goal"""
    user = get_user_account_by_uid(db, current_user_uid)
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    if user.id != onboarding_data.id:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Forbidden action")
    if user.setup_completed:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Onboarding already completed")
    try:
        user_response, goal_response = complete_user_onboarding(db, onboarding_data)
        return {"user": user_response, "goal": goal_response}
    except ValueError as e:
        logger.error(f"Onboarding creation failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Onboarding creation failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")


@router.post("/update/")
async def update_user_profile():
    pass
