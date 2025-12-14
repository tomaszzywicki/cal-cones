from pydantic import BaseModel, UUID4, ConfigDict
from datetime import datetime


class MealProductCreate(BaseModel):
    uuid: UUID4 | None
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


class MealProductUpdate(BaseModel):
    uuid: UUID4
    user_id: int
    product_uuid: UUID4 | None
    name: str | None
    manufacturer: str | None
    kcal: int | None
    carbs: float | None
    protein: float | None
    fat: float | None
    unit_id: int | None
    unit_short: str | None
    conversion_factor: float | None
    amount: float | None
    notes: str | None
    created_at: datetime | None
    last_modified_at: datetime | None

    model_config = ConfigDict(from_attributes=True)
