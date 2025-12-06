from pydantic import BaseModel


class AIResponse(BaseModel):
    name: str
    probability: float
