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
from app.models.meal import Meal
from app.models.meal_product import MealProduct
from app.models.user import User

logger = get_logger(__name__)


def create_meal_with_products(
    db: Session, user_uid: str, meal_data: MealCreate, meal_products: list[MealProductCreate]
):
    """Create a meal along with its associated products for a user"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    meal_uuid = uuid4()

    meal = Meal(
        uuid=meal_uuid,
        user_id=user.id,
        name=meal_data.name,
        total_kcal=meal_data.total_kcal,
        total_carbs=meal_data.total_carbs,
        total_protein=meal_data.total_protein,
        total_fat=meal_data.total_fat,
        notes=meal_data.notes,
        consumed_at=meal_data.created_at,  # na razie załóżmy że to to samo xd
        created_at=meal_data.created_at,
        last_modified_at=meal_data.last_modified_at,
    )

    db.add(meal)
    db.commit()
    db.refresh(meal)

    for product_data in meal_products:
        meal_product = MealProduct(
            uuid=uuid4(),
            meal_uuid=meal_uuid,
            user_id=user.id,
            product_uuid=product_data.product_uuid,
            name=product_data.name,
            manufacturer=product_data.manufacturer,
            kcal=product_data.kcal,
            carbs=product_data.carbs,
            protein=product_data.protein,
            fat=product_data.fat,
            unit_id=product_data.unit_id,
            unit_short=product_data.unit_short,
            conversion_factor=product_data.conversion_factor,
            amount=product_data.amount,
            notes=product_data.notes,
            created_at=product_data.created_at,
            last_modified_at=product_data.last_modified_at,
        )

        db.add(meal_product)

    db.commit()
    return MealResponse.model_validate(meal, from_attributes=True)


def get_user_meals(db: Session, user_uid: str) -> list[MealResponse]:
    """Get all meals for a user"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    meals = db.query(Meal).filter(Meal.user_id == user.id).all()
    return [MealResponse.model_validate(meal, from_attributes=True) for meal in meals]


def get_meal_products(db: Session, meal_uuid: str, user_uid: str) -> list[MealProductResponse]:
    """Get all products for a specific meal of a user"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    meal = db.query(Meal).filter(Meal.uuid == meal_uuid, Meal.user_id == user.id).first()
    if not meal:
        raise ValueError(f"Meal with uuid {meal_uuid} not found for user {user_uid}")

    meal_products = db.query(MealProduct).filter(MealProduct.meal_uuid == meal_uuid).all()
    return [MealProductResponse.model_validate(mp, from_attributes=True) for mp in meal_products]


def delete_meal(db: Session, meal_uuid: str, user_uid: str) -> None:
    """Delete a meal by UUID"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    meal = db.query(Meal).filter(Meal.uuid == meal_uuid, Meal.user_id == user.id).first()
    if not meal:
        raise ValueError(f"Meal with uuid {meal_uuid} not found for user {user_uid}")

    db.delete(meal)
    db.commit()
    return


def delete_meal_product(db: Session, meal_product_uuid: str, user_uid: str) -> None:
    """Delete a meal product by UUID"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    meal_product = (
        db.query(MealProduct)
        .filter(MealProduct.uuid == meal_product_uuid, MealProduct.user_id == user.id)
        .first()
    )
    if not meal_product:
        raise ValueError(f"MealProduct with uuid {meal_product_uuid} not found for user {user_uid}")

    db.delete(meal_product)
    db.commit()
    return


def update_meal_with_products(
    db: Session, user_uid: str, meal_uuid: str, meal_data: MealUpdate, meal_products: list[MealProductCreate]
):
    """Update a meal and its associated products for a user"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    meal = db.query(Meal).filter(Meal.uuid == meal_uuid, Meal.user_id == user.id).first()
    if not meal:
        raise ValueError(f"Meal with uuid {meal_uuid} not found for user {user_uid}")

    # Update meal fields
    for field, value in meal_data.model_dump(exclude_none=True).items():
        setattr(meal, field, value)

    db.commit()
    db.refresh(meal)

    # Delete existing meal products
    db.query(MealProduct).filter(MealProduct.meal_uuid == meal_uuid).delete()

    # Add updated meal products
    for product_data in meal_products:
        meal_product = MealProduct(
            uuid=uuid4(),
            meal_uuid=meal_uuid,
            user_id=user.id,
            product_uuid=product_data.product_uuid,
            name=product_data.name,
            manufacturer=product_data.manufacturer,
            kcal=product_data.kcal,
            carbs=product_data.carbs,
            protein=product_data.protein,
            fat=product_data.fat,
            unit_id=product_data.unit_id,
            unit_short=product_data.unit_short,
            conversion_factor=product_data.conversion_factor,
            amount=product_data.amount,
            notes=product_data.notes,
            created_at=product_data.created_at,
            last_modified_at=product_data.last_modified_at,
        )

        db.add(meal_product)

    db.commit()
    return MealResponse.model_validate(meal, from_attributes=True)
