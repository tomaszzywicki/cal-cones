from pydantic import BaseModel, UUID4
from datetime import date, datetime


class UserGoalCreate(BaseModel):
    user_id: int
    start_date: datetime
    target_date: datetime
    start_weight: float
    target_weight: float
    tempo: float


class UserGoalResponse(BaseModel):
    uuid: UUID4
    user_id: int
    start_date: datetime
    target_date: datetime
    end_date: datetime | None
    start_weight: float
    target_weight: float
    end_weight: float | None
    tempo: float
    is_current: bool
