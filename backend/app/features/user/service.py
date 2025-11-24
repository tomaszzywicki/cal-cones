from datetime import datetime, timezone
from uuid import uuid4
from sqlalchemy.orm import Session

from app.core.logger_setup import get_logger
from app.features.user.schemas import UserOnboardingCreate
from app.features.auth.schemas import UserResponse
from app.features.goal.schemas import GoalResponse
from app.models.user import User
from app.models.goal import Goal

logger = get_logger(__name__)


def complete_user_onboarding(
    db: Session, onboarding_data: UserOnboardingCreate
) -> tuple[UserResponse, GoalResponse]:
    """Complete user onboarding - add user fields and create first goal"""
    user = db.query(User).filter(User.id == onboarding_data.id).first()
    if not user:
        raise ValueError(f"User with id {onboarding_data.id}")

    user.username = onboarding_data.username
    user.birthday = onboarding_data.birthday
    user.sex = onboarding_data.sex
    user.height = onboarding_data.height
    user.diet_type = onboarding_data.diet_type
    user.macro_split = onboarding_data.macro_split
    user.activity_level = onboarding_data.activity_level
    user.setup_completed = True
    user.last_modified_at = datetime.now(timezone.utc)

    goal = Goal(
        uuid=uuid4(),
        user_id=onboarding_data.id,
        start_date=onboarding_data.start_date,
        target_date=onboarding_data.target_date,
        end_date=None,
        start_weight=onboarding_data.start_weight,
        target_weight=onboarding_data.target_weight,
        end_weight=None,
        tempo=onboarding_data.tempo,
        is_current=True,
    )
    db.add(goal)
    db.commit()
    db.refresh(user)
    db.refresh(goal)

    logger.info(f"User onboarding completed for user_id={user.id} with goal_id={goal.uuid}")

    # Debug logging
    logger.debug(f"Goal object: {goal.__dict__}")
    logger.debug(f"Goal fields: uuid={goal.uuid}, user_id={goal.user_id}")

    try:
        goal_response = GoalResponse.model_validate(goal)
        return UserResponse.model_validate(user), goal_response
    except Exception as e:
        logger.error(f"GoalResponse validation failed: {e}")
        logger.error(f"Goal data: {goal.__dict__}")
        raise
