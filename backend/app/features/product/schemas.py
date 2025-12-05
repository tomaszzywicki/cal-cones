from datetime import datetime
from pydantic import BaseModel, ConfigDict, UUID4


class ProductCreate(BaseModel):
    user_id: int
    name: str
    manufacturer: str | None
    kcal: int
    carbs: float
    protein: float
    fat: float
    created_at: datetime
    last_modified_at: datetime
    from_model: bool = False

    model_config = ConfigDict(from_attributes=True)


class ProductResponse(BaseModel):
    uuid: UUID4
    user_id: int
    name: str
    manufacturer: str | None
    kcal: int
    carbs: float
    protein: float
    fat: float
    created_at: datetime
    last_modified_at: datetime
    from_model: bool

    model_config = ConfigDict(from_attributes=True)


class ProductUpdate(BaseModel):
    uuid: UUID4
    user_id: int
    name: str | None
    manufacturer: str | None
    kcal: int | None
    carbs: float | None
    protein: float | None
    fat: float | None
    created_at: datetime | None
    last_modified_at: datetime | None
    from_model: bool | None

    model_config = ConfigDict(from_attributes=True)
