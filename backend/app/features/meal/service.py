from datetime import datetime
from sqlalchemy.orm import Session
from uuid import uuid4

from app.core.logger_setup import get_logger
from app.features.meal.schemas import (
    MealCreate,
    MealProductCreate,
    MealResponse,
    MealProductResponse,
    MealUpdate,
)

# from app.models.meal import Meal
from app.models.meal_product import MealProduct
from app.models.user import User

logger = get_logger(__name__)
