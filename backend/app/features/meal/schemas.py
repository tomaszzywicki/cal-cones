from pydantic import BaseModel, UUID4, ConfigDict
from datetime import datetime

from app.models import user


class MealCreate(BaseModel):
    user_id: int
    name: str
    total_kcal: int
    total_carbs: float
    total_protein: float
    total_fat: float
    notes: str | None
    created_at: datetime
    last_modified_at: datetime

    model_config = ConfigDict(from_attributes=True)


class MealUpdate(BaseModel):
    uuid: UUID4
    user_id: int
    name: str | None
    total_kcal: int | None
    total_carbs: float | None
    total_protein: float | None
    total_fat: float | None
    notes: str | None
    created_at: datetime | None
    last_modified_at: datetime | None

    model_config = ConfigDict(from_attributes=True)


class MealResponse(BaseModel):
    uuid: UUID4
    user_id: int
    name: str
    total_kcal: int
    total_carbs: float
    total_protein: float
    total_fat: float
    notes: str | None
    created_at: datetime
    last_modified_at: datetime

    model_config = ConfigDict(from_attributes=True)


class MealProductCreate(BaseModel):
    user_id: int
    product_uuid: UUID4 | None
    name: str
    manufacturer: str | None
    kcal: int
    carbs: float
    protein: float
    fat: float
    unit_id: int
    unit_short: str
    conversion_factor: float
    amount: float
    notes: str | None
    created_at: datetime
    last_modified_at: datetime

    model_config = ConfigDict(from_attributes=True)


class MealProductResponse(BaseModel):
    uuid: UUID4
    meal_uuid: UUID4
    user_id: int
    product_uuid: UUID4 | None
    name: str
    manufacturer: str | None
    kcal: int
    carbs: float
    protein: float
    fat: float
    unit_id: int
    unit_short: str
    conversion_factor: float
    amount: float
    notes: str | None
    created_at: datetime
    last_modified_at: datetime

    model_config = ConfigDict(from_attributes=True)
