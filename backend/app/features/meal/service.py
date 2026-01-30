from datetime import datetime, timezone
from sqlalchemy.orm import Session
from uuid import uuid4

from app.core.logger_setup import get_logger
from app.features.meal.schemas import MealProductCreate, MealProductResponse, MealProductUpdate

# from app.models.meal import Meal
from app.models.meal_product import MealProduct
from app.models.user import User

logger = get_logger(__name__)


def create_new_meal_product(
    db: Session, meal_product: MealProductCreate, user_uid: str
) -> MealProductResponse:
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with {user_uid} does not exist")

    uuid = meal_product.uuid if meal_product.uuid else uuid4()
    now = datetime.now(tz=timezone.utc)

    new_meal_product = MealProduct(
        uuid=uuid,
        user_id=user.id,
        product_uuid=meal_product.product_uuid,
        name=meal_product.name,
        manufacturer=meal_product.manufacturer,
        kcal=meal_product.kcal,
        carbs=meal_product.carbs,
        protein=meal_product.protein,
        fat=meal_product.fat,
        unit_id=meal_product.unit_id,
        unit_short=meal_product.unit_short,
        conversion_factor=meal_product.conversion_factor,
        amount=meal_product.amount,
        notes=meal_product.notes,
        created_at=meal_product.created_at or now,
        last_modified_at=meal_product.last_modified_at or now,
    )

    db.add(new_meal_product)
    db.commit()
    db.refresh(new_meal_product)

    return MealProductResponse.model_validate(new_meal_product)


def update_meal_product(
    db: Session, meal_product_data: MealProductUpdate, user_uid: str
) -> MealProductResponse:
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} does not exist")

    meal_product = (
        db.query(MealProduct)
        .filter(MealProduct.uuid == meal_product_data.uuid, MealProduct.user_id == user.id)
        .first()
    )
    if not meal_product:
        raise ValueError(f"Meal product with uuid={meal_product_data.uuid} and user_id={user.id} not found")

    update_data = meal_product_data.model_dump(exclude_unset=True, exclude={"uuid"})
    for field, value in update_data.items():
        setattr(meal_product, field, value)

    db.commit()
    db.refresh(meal_product)
    return MealProductResponse.model_validate(meal_product)


def delete_meal_product(db: Session, meal_product_uuid: str, user_uid: str) -> None:
    user = db.query(User).filter(User.uid == user_uid).first()

    if not user:
        raise ValueError(f"User with uid {user_uid} does not exist")

    meal_product = (
        db.query(MealProduct)
        .filter(MealProduct.uuid == meal_product_uuid, MealProduct.user_id == user.id)
        .first()
    )
    if not meal_product:
        logger.warning(
            f"Meal product with uuid={meal_product_uuid} and user_id={user.id} not found, may be already deleted"
        )
        return

    db.delete(meal_product)
    db.commit()


def get_all_meal_products(db: Session, user_uid: str) -> list[MealProductResponse]:
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} does not exist")

    meal_products = db.query(MealProduct).filter(MealProduct.user_id == user.id).all()
    return [MealProductResponse.model_validate(mp) for mp in meal_products]
