from fastapi import FastAPI

app = FastAPI(title='CalCones API',
              description='API for CalCones app',
              version="1.0.0")

@app.get("/")
async def read_root():
    return {"message": "Hello root"}

@app.get("/test")
async def test():
    return {}