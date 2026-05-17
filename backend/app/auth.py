"""
Authentication and authorization module for AgriAgent API.
Provides API key validation and token-based security.
"""

import os
import logging
from typing import Optional
from fastapi import Header, HTTPException, status

logger = logging.getLogger(__name__)

# API keys management (in production, use database)
VALID_API_KEYS = set()

def load_api_keys():
    """Load valid API keys from environment."""
    keys_str = os.getenv("VALID_API_KEYS", "")
    if keys_str:
        VALID_API_KEYS.update(keys_str.split(","))
    
    # For development, allow empty validation
    if os.getenv("ENVIRONMENT") == "development":
        logger.warning("Development mode: API key validation disabled")
        return
    
    if not VALID_API_KEYS:
        logger.warning("No API keys configured in production. All requests will be rejected.")


async def verify_api_key(x_api_key: Optional[str] = Header(None)) -> str:
    """
    Verify API key from request header.
    
    Args:
        x_api_key: API key from X-API-Key header
        
    Returns:
        The validated API key
        
    Raises:
        HTTPException: If key is invalid or missing in production
    """
    environment = os.getenv("ENVIRONMENT", "development")
    
    # Development: Allow requests without key
    if environment == "development":
        return x_api_key or "dev-key"
    
    # Production: Require valid API key
    if not x_api_key:
        logger.warning("Request missing API key header")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing X-API-Key header"
        )
    
    if x_api_key not in VALID_API_KEYS:
        logger.warning(f"Invalid API key attempted: {x_api_key[:10]}...")
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid API key"
        )
    
    return x_api_key


def validate_secret_key() -> str:
    """
    Get or generate SECRET_KEY for JWT signing.
    In production, this should be loaded from secure secret management.
    """
    secret = os.getenv("SECRET_KEY")
    if not secret:
        if os.getenv("ENVIRONMENT") == "production":
            logger.error("SECRET_KEY not configured in production!")
            raise ValueError("SECRET_KEY must be set in production")
        # Generate a temporary key for development
        import secrets
        secret = secrets.token_hex(32)
        logger.warning("Generated temporary SECRET_KEY for development")
    
    return secret
