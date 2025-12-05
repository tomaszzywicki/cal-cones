from enum import Enum
from sqlalchemy import Boolean, Float, Integer, String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.dialects.postgresql import ENUM
from app.core.database import Base
from typing import TYPE_CHECKING, List

if TYPE_CHECKING:
    from app.models.meal_product import MealProduct


class UnitTypeEnum(str, Enum):
    MASS = "MASS"
    VOLUME = "VOLUME"
    COUNT = "COUNT"


class Unit(Base):
    __tablename__ = "units"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    name: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    shortname: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    unit_type: Mapped[UnitTypeEnum] = mapped_column(ENUM(UnitTypeEnum), nullable=False)
    conversion_factor: Mapped[float] = mapped_column(Float, nullable=False)  # to grams or milliliters
    base_unit: Mapped[bool] = mapped_column(Boolean, default=False)

    # Relationships
    meal_products: Mapped[List["MealProduct"]] = relationship("MealProduct", back_populates="unit")
