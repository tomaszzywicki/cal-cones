from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status

from sqlalchemy.orm import Session
from app.core.logger_setup import get_logger
from app.core.dependencies import get_current_user_uid, get_db
from app.features.product.schemas import ProductCreate, ProductResponse, ProductUpdate
from app.features.product.service import (
    add_product,
    get_user_products,
    update_product,
    delete_product,
    search_products,
)

logger = get_logger(__name__)

router = APIRouter(prefix="/product", tags=["product"])


@router.post("/create", response_model=ProductResponse, status_code=status.HTTP_201_CREATED)
async def create_user_product(
    product_data: ProductCreate,
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    """Add a new product for the current user"""
    try:
        product_response = add_product(db, product_data, current_user_uid)
        return product_response
    except ValueError as e:
        logger.error(f"Add product failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Add product failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")


@router.get("/added/", response_model=list[ProductResponse], status_code=status.HTTP_200_OK)
async def get_all_user_products(
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    """Get all products for the current user"""
    try:
        products = get_user_products(db, current_user_uid)
        return products
    except ValueError as e:
        logger.error(f"Get user products failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Get user products failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")


@router.put("/update", response_model=ProductResponse, status_code=status.HTTP_200_OK)
async def update_user_product(
    product_data: ProductUpdate,
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    """Update a product for the current user"""
    try:
        product_response = update_product(db, product_data, current_user_uid)
        return product_response
    except ValueError as e:
        logger.error(f"Update product failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Update product failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")


@router.delete("/delete/{uuid}", response_model=None, status_code=status.HTTP_200_OK)
async def delete_user_product(
    uuid: str,
    db: Session = Depends(get_db),
    current_user_uid: str = Depends(get_current_user_uid),
):
    """Delete a product for the current user"""
    try:
        delete_product(db, uuid, current_user_uid)
        return
    except ValueError as e:
        logger.error(f"Delete product failed: {e}")
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except Exception as e:
        logger.error(f"Delete product failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")


@router.get("/search/{query}", response_model=list[ProductResponse], status_code=status.HTTP_200_OK)
async def search_all_products(
    query: str,
    db: Session = Depends(get_db),
):
    """Search products in the database"""
    try:
        products = search_products(db, query or "")
        return products
    except Exception as e:
        logger.error(f"Search products failed: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error")
