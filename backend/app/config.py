import os
from pathlib import Path

# PostgreSQL
user = os.getenv("POSTGRES_USER")
password = os.getenv("POSTGRES_PASSWORD")
db = os.getenv("POSTGRES_DB")
host = os.getenv("POSTGRES_HOST", "calcones_db")
port = os.getenv("POSTGRES_PORT", "5432")

DATABASE_URL = f"postgresql+psycopg://{user}:{password}@{host}:{port}/{db}"

# Firebase
FIREBASE_KEY_PATH = Path("/app/app/cal-cones-firebase-adminsdk-fbsvc-c2ea5e8376.json")
