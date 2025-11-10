from sqlalchemy import String, Date, Integer, DateTime
from sqlalchemy.dialects.postgresql import ENUM, BOOLEAN
from sqlalchemy.orm import Mapped, mapped_column
from datetime import date, datetime, timezone

from app.database import Base


class User(Base):
    __tablename__ = "users"
    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    uid: Mapped[str] = mapped_column(
        String(30), unique=True
    )  # TODO nie pamiętam ile to ma zmienić potem
    email: Mapped[str] = mapped_column(String(100))
    username: Mapped[str] = mapped_column(String(30), nullable=True, unique=True)
    birthday: Mapped[date] = mapped_column(Date)
    sex: Mapped[str] = mapped_column(String(6))  # Male / Female
    height: Mapped[int] = mapped_column(Integer)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, default=datetime.now(timezone.utc)
    )
    last_modified_at: Mapped[datetime] = mapped_column(DateTime)
    # diet_type  # TODO jak to zrobić
    activity_level: Mapped[str] = mapped_column(String)  # TODO tu potem enum
    setup_completed: Mapped[bool] = mapped_column(BOOLEAN, default=False)
