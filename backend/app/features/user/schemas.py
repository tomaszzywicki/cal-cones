"""Pydantic models for User"""

from pydantic import BaseModel
from datetime import date, datetime


class UserInfoCreate(BaseModel):
    id: int
    uid: str
    email: str
    username: str
    birthday: date
    sex: str
    height: int
    created_at: datetime
    last_modified_at: datetime
    diet_type: str
    activity_level: str
    setup_completed: bool
