from datetime import datetime
from pydantic import UUID4
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy import ForeignKey, Integer, DateTime, Float

from app.core.database import Base

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.user import User


class WeightLog(Base):
    __tablename__ = "weight_logs"
    uuid: Mapped[UUID4] = mapped_column(UUID, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"))
    weight: Mapped[float] = mapped_column(Float)
    created_at: Mapped[datetime] = mapped_column(DateTime)
    last_modified_at: Mapped[datetime] = mapped_column(DateTime)

    # Relationship
    user: Mapped["User"] = relationship("User", back_populates="weight_logs")
