from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from dotenv import load_dotenv
import os
import time
from collections import defaultdict

load_dotenv()

from app.api import router

# ============================================
# APP CONFIGURATION
# ============================================
app = FastAPI(
    title="AgriAgent API",
    version="1.0.0",
    description="AI-powered agricultural assistant API"
)

# ============================================
# SECURITY: CORS Configuration
# ============================================
# Read allowed origins from environment, with safe defaults
ENVIRONMENT = os.getenv("ENVIRONMENT", "development")
ALLOWED_ORIGINS_STR = os.getenv("ALLOWED_ORIGINS", "")

if ENVIRONMENT == "production":
    # Production: Only allow specified origins
    allowed_origins = [origin.strip() for origin in ALLOWED_ORIGINS_STR.split(",") if origin.strip()]
    if not allowed_origins:
        allowed_origins = []  # No CORS if not configured in production
else:
    # Development: Allow common dev origins
    allowed_origins = [
        "http://localhost:3000",
        "http://127.0.0.1:8000",
        "http://10.0.2.2:8000",  # Android emulator
        "http://172.20.10.8:8000",  # Local network
    ]
    # Also allow any specified in env
    if ALLOWED_ORIGINS_STR:
        allowed_origins.extend([origin.strip() for origin in ALLOWED_ORIGINS_STR.split(",") if origin.strip()])

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins if ENVIRONMENT == "production" else ["*"],  # Dev allows all for testing
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

# ============================================
# SECURITY: Rate Limiting (Simple In-Memory)
# ============================================
RATE_LIMIT_REQUESTS = int(os.getenv("RATE_LIMIT_REQUESTS", "100"))
RATE_LIMIT_WINDOW = int(os.getenv("RATE_LIMIT_WINDOW_SECONDS", "60"))

# Simple in-memory rate limiter (use Redis in production)
request_counts = defaultdict(list)

@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    # Skip rate limiting in development
    if ENVIRONMENT == "development":
        return await call_next(request)
    
    client_ip = request.client.host
    current_time = time.time()
    
    # Clean old requests
    request_counts[client_ip] = [
        t for t in request_counts[client_ip] 
        if current_time - t < RATE_LIMIT_WINDOW
    ]
    
    # Check limit
    if len(request_counts[client_ip]) >= RATE_LIMIT_REQUESTS:
        return JSONResponse(
            status_code=429,
            content={"detail": "Too many requests. Please slow down."}
        )
    
    # Record this request
    request_counts[client_ip].append(current_time)
    
    return await call_next(request)

# ============================================
# SECURITY: Global Exception Handler
# ============================================
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    # Log the error (in production, send to monitoring service)
    import logging
    logging.error(f"Unhandled exception: {exc}", exc_info=True)
    
    # Return generic error (don't expose internal details)
    return JSONResponse(
        status_code=500,
        content={"detail": "An internal error occurred. Please try again later."}
    )

# ============================================
# ROUTES
# ============================================
app.include_router(router, prefix="/api/v1")

@app.get("/")
def read_root():
    return {"message": "Welcome to AgriAgent API", "version": "1.0.0"}

@app.get("/health")
def health_check():
    return {"status": "ok", "environment": ENVIRONMENT}
