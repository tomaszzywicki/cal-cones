"""Pydantic models for User"""

from pydantic import BaseModel
from datetime import date, datetime
from app.models.user import DietTypeEnum, ActivityLevelEnum, SexEnum


class UserOnboardingCreate(BaseModel):
    id: int
    uid: str
    username: str
    birthday: date
    sex: SexEnum
    height: int
    diet_type: DietTypeEnum
    macro_split: dict
    activity_level: ActivityLevelEnum
    start_date: datetime
    target_date: datetime
    start_weight: float
    target_weight: float
    tempo: float


class UserOnboardingResponse(BaseModel):
    id: int
    uid: str
    username: str
    birthday: date
    sex: SexEnum
    height: int
    diet_type: DietTypeEnum
    macro_split: dict
    activity_level: ActivityLevelEnum
    start_date: datetime
    target_date: datetime
    start_weight: float
    target_weight: float
    tempo: float
