from datetime import datetime
from pydantic import UUID4
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import ForeignKey, String, Integer, Float, DateTime
from sqlalchemy.dialects.postgresql import UUID, BOOLEAN
from app.core.database import Base

from typing_extensions import TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.user import User


class Product(Base):
    __tablename__ = "products"
    uuid: Mapped[UUID4] = mapped_column(UUID, primary_key=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"))
    name: Mapped[str] = mapped_column(String)
    manufacturer: Mapped[str] = mapped_column(String, nullable=True)
    kcal: Mapped[int] = mapped_column(Integer)
    carbs: Mapped[float] = mapped_column(Float)
    protein: Mapped[float] = mapped_column(Float)
    fat: Mapped[float] = mapped_column(Float)
    created_at: Mapped[datetime] = mapped_column(DateTime)
    last_modified_at: Mapped[datetime] = mapped_column(DateTime)
    from_model: Mapped[bool] = mapped_column(BOOLEAN)

    # Relationship
    user: Mapped["User"] = relationship("User", back_populates="products")
