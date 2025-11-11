## Backend Project Structure

```plaintext
backend/
├── alembic/                    # Migrations
│   └── versions/
├── app/
│   ├── main.py                 # FastAPI app
│   ├── config.py               # Global settings
│   │
│   ├── core/                   # Shared infrastructure
│   │   ├── database.py         # SQLAlchemy setup
│   │   ├── firebase.py         # Firebase Admin SDK
│   │   ├── security.py         # JWT verification
│   │   ├── exceptions.py       # Custom exceptions
│   │   └── dependencies.py     # Shared dependencies (get_db)
│   │
│   ├── models/                 # ✅ WSZYSTKIE SQLAlchemy models
│   │   ├── __init__.py         # Import all for Alembic
│   │   ├── user.py
│   │   ├── product.py
│   │   ├── meal.py
│   │   ├── meal_product.py
│   │   └── weight_log.py
│   │
│   ├── features/               # Feature modules (business logic)
│   │   │
│   │   ├── auth/
│   │   │   ├── router.py       # FastAPI routes
│   │   │   ├── schemas.py      # Pydantic (request/response)
│   │   │   ├── service.py      # Business logic
│   │   │   └── dependencies.py # Auth-specific deps
│   │   │
│   │   ├── products/
│   │   │   ├── router.py
│   │   │   ├── schemas.py
│   │   │   ├── service.py      # CRUD operations
│   │   │   └── dependencies.py
│   │   │
│   │   ├── meals/
│   │   │   ├── router.py
│   │   │   ├── schemas.py
│   │   │   ├── service.py
│   │   │   └── utils.py        # Macro calculations
│   │   │
│   │   ├── weight/
│   │   │   ├── router.py
│   │   │   ├── schemas.py
│   │   │   └── service.py
│   │   │
│   │   └── food_recognition/
│   │       ├── router.py
│   │       ├── schemas.py
│   │       ├── model_loader.py
│   │       └── predict.py
│   │
│   └── services/               # External integrations (optional)
│       └── firebase_client.py
│
├── tests/
│   ├── test_auth.py
│   ├── test_products.py
│   └── test_meals.py
│
├── requirements.txt
├── .env
└── Dockerfile
```