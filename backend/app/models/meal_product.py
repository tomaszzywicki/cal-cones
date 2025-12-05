from datetime import datetime
from pydantic import UUID4
from sqlalchemy import Float, Integer, ForeignKey, String, DateTime
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import UUID
from app.core.database import Base

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.user import User

    # from app.models.meal import Meal
    from app.models.product import Product
    from app.models.unit import Unit


class MealProduct(Base):
    __tablename__ = "meal_products"
    uuid: Mapped[UUID4] = mapped_column(UUID, primary_key=True)
    # meal_uuid: Mapped[UUID4] = mapped_column(
    #     UUID,
    #     ForeignKey("meals.uuid", ondelete="CASCADE"),
    # )
    user_id: Mapped[int] = mapped_column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    product_uuid: Mapped[UUID4] = mapped_column(
        UUID, ForeignKey("products.uuid", ondelete="SET NULL"), nullable=True
    )
    name: Mapped[str] = mapped_column(String)
    manufacturer: Mapped[str] = mapped_column(String)
    kcal: Mapped[int] = mapped_column(Integer)
    carbs: Mapped[float] = mapped_column(Float)
    protein: Mapped[float] = mapped_column(Float)
    fat: Mapped[float] = mapped_column(Float)
    unit_id: Mapped[int] = mapped_column(Integer, ForeignKey("units.id"), nullable=False)
    unit_short: Mapped[str] = mapped_column(String)
    conversion_factor: Mapped[float] = mapped_column(Float)
    amount: Mapped[float] = mapped_column(Float)
    notes: Mapped[str] = mapped_column(String)
    created_at: Mapped[datetime] = mapped_column(DateTime)
    last_modified_at: Mapped[datetime] = mapped_column(DateTime)

    # Relationships
    # meal = relationship("Meal", back_populates="meal_products")
    user = relationship("User", back_populates="meal_products")
    product = relationship("Product", back_populates="meal_products")
    unit = relationship("Unit", back_populates="meal_products")
