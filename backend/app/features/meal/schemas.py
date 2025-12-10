from pydantic import BaseModel, UUID4, ConfigDict
from datetime import datetime


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
