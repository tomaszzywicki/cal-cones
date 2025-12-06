from uuid import uuid4
from sqlalchemy.orm import Session

from app.models.product import Product
from app.models.user import User
from app.features.product.schemas import ProductCreate, ProductUpdate, ProductResponse
from app.core.logger_setup import get_logger

logger = get_logger(__name__)


def add_product(db: Session, product_data: ProductCreate, user_uid: str) -> ProductResponse:
    """Add a new custom product"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    new_product = ProductCreate(
        user_id=user.id,
        name=product_data.name,
        manufacturer=product_data.manufacturer,
        kcal=product_data.kcal,
        carbs=product_data.carbs,
        protein=product_data.protein,
        fat=product_data.fat,
        created_at=product_data.created_at,
        last_modified_at=product_data.last_modified_at,
        from_model=product_data.from_model,
    )
    db.add(new_product)
    db.commit()
    db.refresh(new_product)
    return ProductResponse.model_validate(new_product)


def get_user_products(db: Session, user_uid: str) -> list[ProductResponse]:
    """Get all products for a user"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    products = db.query(Product).filter(Product.user_id == user.id).all()
    return [ProductResponse.model_validate(product) for product in products]


def update_product(db: Session, product_data: ProductUpdate, user_uid: str) -> ProductResponse:
    """Update an existing product"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    product = db.query(Product).filter(Product.uuid == product_data.uuid, Product.user_id == user.id).first()
    if not product:
        raise ValueError(f"Product with uuid {product_data.uuid} not found for user {user_uid}")

    for field, value in product_data.model_dump(exclude_unset=True).items():
        setattr(product, field, value)

    db.commit()
    db.refresh(product)
    return ProductResponse.model_validate(product)


def delete_product(db: Session, product_uuid: str, user_uid: str) -> None:
    """Delete a product by UUID"""
    user = db.query(User).filter(User.uid == user_uid).first()
    if not user:
        raise ValueError(f"User with uid {user_uid} not found")

    product = db.query(Product).filter(Product.uuid == product_uuid, Product.user_id == user.id).first()
    if not product:
        raise ValueError(f"Product with uuid {product_uuid} not found for user {user_uid}")

    db.delete(product)
    db.commit()


def search_products(db: Session, query: str) -> list[ProductResponse]:
    """Search products in the database"""
    query = query.strip()
    products = db.query(Product).filter(Product.name.ilike(f"%{query}%")).all()
    return [ProductResponse.model_validate(product) for product in products]


def get_product_from_model(db: Session, name_from_model: str) -> ProductResponse:
    product = db.query(Product).filter(Product.name_from_model == name_from_model).first()
    return ProductResponse.model_validate(product)
