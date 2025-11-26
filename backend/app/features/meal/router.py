from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.logger_setup import get_logger
from app.core.dependencies import get_current_user_uid, get_db
from app.features.meal.schemas import MealCreate, MealProductCreate, MealUpdate
from app.features.meal.service import (
    create_meal_with_products,
    delete_meal,
    get_meal_products,
    get_user_meals,
    update_meal_with_products,
)

from app.core.logger_setup import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/meal", tags=["meal"])


@router.post("/create/", status_code=status.HTTP_201_CREATED)
async def create_meal_with_product_data(
    meal_data: MealCreate,
    meal_products: list[MealProductCreate],
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    try:
        meal_response = create_meal_with_products(db, current_user_uid, meal_data, meal_products)
        return meal_response
    except ValueError as e:
        logger.error(f"Meal creation failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Meal creation failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")


@router.get("/all/", status_code=status.HTTP_200_OK)
async def get_all_user_meals(
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    try:
        meals = get_user_meals(db, current_user_uid)
        return meals
    except ValueError as e:
        logger.error(f"Fetching user meals failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Fetching user meals failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")


@router.get("/{meal_uuid}/products/", status_code=status.HTTP_200_OK)
async def get_all_meal_products(
    meal_uuid: str,
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    try:
        meal_products = get_meal_products(db, meal_uuid, current_user_uid)
        return meal_products
    except ValueError as e:
        logger.error(f"Fetching meal products failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Fetching meal products failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")


@router.delete("/{meal_uuid}/delete/", status_code=status.HTTP_200_OK)
async def delete_user_meal(
    meal_uuid: str,
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    try:
        delete_meal(db, meal_uuid, current_user_uid)
        return {"detail": "Meal deleted successfully"}
    except ValueError as e:
        logger.error(f"Deleting meal failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Deleting meal failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")


@router.put("/{meal_uuid}/update/", status_code=status.HTTP_200_OK)
async def update_meal_with_products_data(
    meal_uuid: str,
    meal_data: MealUpdate,
    meal_products: list[MealProductCreate],
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    try:
        meal_response = update_meal_with_products(db, current_user_uid, meal_uuid, meal_data, meal_products)
        return meal_response
    except ValueError as e:
        logger.error(f"Updating meal failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Updating meal failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")
