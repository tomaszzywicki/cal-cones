from datetime import datetime
from pydantic import UUID4
from sqlalchemy import Float, Integer, ForeignKey, String, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.core.database import Base


class Meal(Base):
    __tablename__ = "meals"
    uuid: Mapped[UUID4] = mapped_column(UUID, primary_key=True)
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id"))
    name: Mapped[str] = mapped_column(
        String,
    )
    total_kcal: Mapped[int] = mapped_column(Integer)
    total_carbs: Mapped[float] = mapped_column(Float)
    total_protein: Mapped[float] = mapped_column(Float)
    total_fat: Mapped[float] = mapped_column(Float)
    notes: Mapped[str] = mapped_column(String)
    consumed_at: Mapped[datetime] = mapped_column(DateTime)
    created_at: Mapped[datetime] = mapped_column(DateTime)
    last_modified_at: Mapped[datetime] = mapped_column(DateTime)

    # Relationships
    user = relationship("User", back_populates="meals")
    meal_products = relationship("MealProduct", back_populates="meal")
