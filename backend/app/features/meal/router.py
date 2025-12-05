from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.logger_setup import get_logger
from app.core.dependencies import get_current_user_uid, get_db
from app.features.meal.schemas import MealCreate, MealProductCreate, MealUpdate

from app.core.logger_setup import get_logger

logger = get_logger(__name__)

router = APIRouter(prefix="/meal", tags=["meal"])
