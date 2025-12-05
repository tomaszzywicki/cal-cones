from fastapi import APIRouter, Depends, HTTPException, status

from app.core.logger_setup import get_logger
from app.core.dependencies import get_current_user_uid, get_db

logger = get_logger(__name__)

router = APIRouter(prefix="/goal", tags=["goal"])


@router.get("create/", response_model=None, status_code=status.HTTP_201_CREATED)
async def create_goal(
    goal_data: None,
    db=Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    """Create a new goal for the current user"""
    pass


async def get_goals(
    db=Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    """Get all goals for the current user"""
    pass
