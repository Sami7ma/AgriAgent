from fastapi import FastAPI
from dotenv import load_dotenv
import os

load_dotenv()

from app.api import router

app = FastAPI(title="AgriAgent API", version="0.1.0")
app.include_router(router, prefix="/api/v1")


@app.get("/")
def read_root():
    return {"message": "Welcome to AgriAgent API"}

@app.get("/health")
def health_check():
    return {"status": "ok"}
