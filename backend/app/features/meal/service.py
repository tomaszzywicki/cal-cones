from datetime import datetime
from sqlalchemy.orm import Session
from uuid import uuid4

from app.core.logger_setup import get_logger
from app.features.meal.schemas import (
    MealProductCreate,
    MealProductResponse,
)

# from app.models.meal import Meal
from app.models.meal_product import MealProduct
from app.models.user import User

logger = get_logger(__name__)


def create_new_meal_product(db: Session, meal_product: MealProductCreate):
    pass


def update_meal_product(db: Session, meal_product: MealProductCreate):
    pass


def delete_meal_product(db: Session, meal_product_uuid: int):
    pass


def get_all_meal_products(db: Session, user_id):
    pass
