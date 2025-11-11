from pydantic import BaseModel, EmailStr
from datetime import datetime, date


class UserCreate(BaseModel):
    uid: str
    email: EmailStr


class UserResponse(BaseModel):
    id: int
    uid: str
    email: EmailStr
    username: str | None
    birthday: date | None
    sex: str | None
    height: int | None
    created_at: datetime
    last_modified_at: datetime
    # diet_type: str | None
    activity_level: str | None
    setup_completed: bool

    class Config:
        from_attributes = True
