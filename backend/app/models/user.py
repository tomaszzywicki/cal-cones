from enum import Enum
from sqlalchemy import String, Date, Integer, DateTime
from sqlalchemy.dialects.postgresql import ENUM, BOOLEAN, JSON
from sqlalchemy.orm import Mapped, mapped_column
from datetime import date, datetime, timezone

from app.core.database import Base


class DietTypeEnum(str, Enum):
    BALANCED = "balanced"       # 40/30/30
    MUSCLE_GAIN = "muscle_gain" # 40/40/20
    ENUDRANCE = "endurance"     # 60/20/20
    KETO = "keto"               # 5/25/70
    CUSTOM = "custom"           # custom


class ActivityLevelEnum(str, Enum):
    SEDENTARY = "sedentary"
    LIGHTLY_ACTIVE = "lightly_active"
    MODERATELY_ACTIVE = "moderately_active"
    VERY_ACTIVE = "very_active"
    SUPER_ACTIVE = "super_active"

class SexEnum(str, Enum):
    MALE = "male"
    FEMALE = "female"

class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    uid: Mapped[str] = mapped_column(
        String(30), unique=True
    )  # TODO nie pamiętam ile to ma zmienić potem
    email: Mapped[str] = mapped_column(String(100))
    username: Mapped[str] = mapped_column(String(30), nullable=True, unique=True)
    birthday: Mapped[date] = mapped_column(Date, nullable=True)
    sex: Mapped[SexEnum] = mapped_column(ENUM(SexEnum), nullable=True)
    height: Mapped[int] = mapped_column(Integer, nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.now(timezone.utc)
    )
    last_modified_at: Mapped[datetime] = mapped_column(DateTime)
    diet_type: Mapped[DietTypeEnum] = mapped_column(ENUM(DietTypeEnum), nullable=True)
    macro_split: Mapped[dict] = mapped_column(JSON, nullable=True)
    activity_level: Mapped[ActivityLevelEnum] = mapped_column(
        ENUM(ActivityLevelEnum), nullable=True
    )
    setup_completed: Mapped[bool] = mapped_column(BOOLEAN, default=False)