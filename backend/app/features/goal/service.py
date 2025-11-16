from uuid import uuid4
from sqlalchemy.orm import Session

from app.core.logger_setup import get_logger
from app.models.goal import Goal
from .schemas import UserGoalCreate, UserGoalResponse

logger = get_logger(__name__)


def create_goal(db: Session, goal_data: UserGoalCreate) -> UserGoalResponse:
    """Creates a new user goal in a database"""
    pass
    db_goal = Goal(
        uuid=uuid4(),
        user_id=goal_data.user_id,
        start_date=goal_data.start_date,
        target_date=goal_data.target_date,
        end_date=None,
        start_weight=goal_data.start_weight,
        target_weight=goal_data.target_weight,
        end_weight=None,
        tempo=goal_data.tempo,
        is_current=True,
    )
    db.add(db_goal)
    db.commit()
    db.refresh(db_goal)
    return UserGoalResponse.model_validate(db_goal)


def deactivate_goal(db: Session, goal_uuid):
    pass
