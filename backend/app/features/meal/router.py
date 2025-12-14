from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.logger_setup import get_logger
from app.core.dependencies import get_current_user_uid, get_db
from app.features.meal.schemas import MealProductCreate, MealProductResponse, MealProductUpdate
from app.features.meal.service import (
    create_new_meal_product,
    update_meal_product,
    delete_meal_product,
    get_all_meal_products,
)

from app.core.logger_setup import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/meal-product", tags=["meal"])


@router.post("/create", response_model=MealProductResponse, status_code=status.HTTP_201_CREATED)
def create_meal_product(
    meal_product: MealProductCreate,
    db: Session = Depends(get_db),
    user_uid: str = Depends(get_current_user_uid),
):
    try:
        new_meal_product = create_new_meal_product(db, meal_product, user_uid)
        return new_meal_product
    except ValueError as e:
        logger.error(f"Error creating meal product: {e}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.put("/update", response_model=MealProductResponse, status_code=status.HTTP_200_OK)
def update_meal_product_endpoint(
    meal_product: MealProductUpdate,
    db: Session = Depends(get_db),
    user_uid: str = Depends(get_current_user_uid),
):
    try:
        updated_meal_product = update_meal_product(db, meal_product, user_uid)
        return updated_meal_product
    except ValueError as e:
        logger.error(f"Error updating meal product: {e}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.delete("/delete/{meal_product_uuid}", status_code=status.HTTP_204_NO_CONTENT)
def delete_meal_product_endpoint(
    meal_product_uuid: str,
    db: Session = Depends(get_db),
    user_uid: str = Depends(get_current_user_uid),
):
    try:
        delete_meal_product(db, meal_product_uuid, user_uid)
    except ValueError as e:
        logger.error(f"Error deleting meal product: {e}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/all", response_model=list[MealProductResponse], status_code=status.HTTP_200_OK)
def get_all_meal_products_endpoint(
    db: Session = Depends(get_db),
    user_uid: str = Depends(get_current_user_uid),
):
    try:
        meal_products = get_all_meal_products(db, user_uid)
        return meal_products
    except ValueError as e:
        logger.error(f"Error retrieving meal products: {e}")
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
