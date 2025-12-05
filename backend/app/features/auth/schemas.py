from pydantic import BaseModel, EmailStr
from datetime import datetime, date

from app.models.user import DietTypeEnum, ActivityLevelEnum, SexEnum

class UserCreate(BaseModel):
    uid: str
    email: EmailStr


class UserResponse(BaseModel):
    id: int
    uid: str
    email: EmailStr
    username: str | None
    birthday: date | None
    sex: SexEnum | None
    height: int | None
    created_at: datetime
    last_modified_at: datetime
    diet_type: DietTypeEnum | None
    macro_split: dict | None
    activity_level: ActivityLevelEnum | None
    setup_completed: bool

    class Config:
        from_attributes = True
