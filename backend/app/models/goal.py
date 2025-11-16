from datetime import datetime
from pydantic import UUID4
from uuid import uuid4
from sqlalchemy import Boolean, String, Date, Integer, DateTime, ForeignKey, Float
from sqlalchemy.dialects.postgresql import UUID, BOOLEAN
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from typing import TYPE_CHECKING


class Goal(Base):
    __tablename__ = "goals"
    uuid: Mapped[UUID4] = mapped_column(UUID, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    start_date: Mapped[datetime] = mapped_column(DateTime)
    target_date: Mapped[datetime] = mapped_column(DateTime)
    end_date: Mapped[datetime] = mapped_column(DateTime, nullable=True)
    start_weight: Mapped[float] = mapped_column(Float)
    target_weight: Mapped[float] = mapped_column(Float)
    end_weight: Mapped[float] = mapped_column(Float, nullable=True)
    tempo: Mapped[float] = mapped_column(Float)  # kg/week
    is_current: Mapped[bool] = mapped_column(BOOLEAN, default=True)

    # relationship
    user: Mapped["User"] = relationship("User", back_populates="goals")  # type: ignore
