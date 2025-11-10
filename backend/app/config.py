import os

user = os.getenv("POSTGRES_USER")
password = os.getenv("POSTGRES_PASSWORD")
db = os.getenv("POSTGRES_DB")
host = os.getenv("POSTGRES_HOST", "calcones_db")
port = os.getenv("POSTGRES_PORT", "5432")

DATABASE_URL = f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}"