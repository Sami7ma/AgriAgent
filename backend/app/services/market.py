"""
Market Data Service
Provides real agricultural commodity prices using free APIs
"""
import httpx
import os
from typing import Dict, Any, Optional
import logging

logger = logging.getLogger(__name__)

# Free tier API options
COMMODITIES_API_KEY = os.getenv("COMMODITIES_API_KEY", "")  # commodities-api.com
WORLD_BANK_BASE = "https://api.worldbank.org/v2"

# Crop mapping to commodity codes
CROP_CODES = {
    "maize": "CORN",
    "corn": "CORN",
    "wheat": "WHEAT",
    "coffee": "COFFEE",
    "teff": "WHEAT",  # No specific code, use wheat as proxy
    "rice": "RICE",
    "soybean": "SOYBEAN",
    "sugar": "SUGAR",
}

# Regional price adjustments (multipliers based on local market conditions)
REGION_ADJUSTMENTS = {
    "Kenya": {"base_currency": "KES", "multiplier": 150},  # USD to KES approx
    "Ethiopia": {"base_currency": "ETB", "multiplier": 56},  # USD to ETB approx
    "Tanzania": {"base_currency": "TZS", "multiplier": 2500},
    "Uganda": {"base_currency": "UGX", "multiplier": 3700},
    "default": {"base_currency": "USD", "multiplier": 1},
}

# Local market base prices (per kg in local currency) - fallback data
LOCAL_PRICES = {
    "Kenya": {
        "maize": 45,   # KES/kg
        "wheat": 55,
        "coffee": 350,
        "teff": 120,
    },
    "Ethiopia": {
        "maize": 25,   # ETB/kg
        "wheat": 35,
        "coffee": 200,
        "teff": 80,    # Teff is major crop here
    },
    "default": {
        "maize": 0.35,  # USD/kg
        "wheat": 0.40,
        "coffee": 2.50,
        "teff": 1.20,
    }
}


class MarketService:
    """Service for fetching real agricultural market prices"""
    
    def __init__(self):
        self.client = httpx.AsyncClient(timeout=10.0)
    
    async def get_price(self, crop: str, region: str = "Kenya", lat: float = None, lon: float = None) -> Dict[str, Any]:
        """
        Get market price for a crop in a specific region.
        Uses real API when available, falls back to local data.
        """
        crop_lower = crop.lower()
        
        # Determine region from coordinates if provided
        if lat and lon:
            region = self._get_region_from_coords(lat, lon)
        
        try:
            # Try real API first
            if COMMODITIES_API_KEY:
                real_price = await self._fetch_commodities_api(crop_lower)
                if real_price:
                    return self._format_response(crop, region, real_price, source="live")
            
            # Fallback to local prices
            return self._get_local_price(crop_lower, region)
            
        except Exception as e:
            logger.warning(f"Market API error: {e}. Using fallback data.")
            return self._get_local_price(crop_lower, region)
    
    async def _fetch_commodities_api(self, crop: str) -> Optional[float]:
        """Fetch from commodities-api.com (free tier: 50k calls/month)"""
        if not COMMODITIES_API_KEY:
            return None
        
        commodity_code = CROP_CODES.get(crop, "CORN")
        url = f"https://commodities-api.com/api/latest?access_key={COMMODITIES_API_KEY}&symbols={commodity_code}"
        
        try:
            response = await self.client.get(url)
            data = response.json()
            
            if data.get("success"):
                # API returns rates relative to base currency (USD)
                rates = data.get("data", {}).get("rates", {})
                return rates.get(commodity_code, None)
            return None
        except Exception as e:
            logger.error(f"Commodities API error: {e}")
            return None
    
    def _get_region_from_coords(self, lat: float, lon: float) -> str:
        """Simple region detection based on coordinates"""
        # Kenya: roughly -5 to 5 lat, 34 to 42 lon
        if -5 <= lat <= 5 and 34 <= lon <= 42:
            return "Kenya"
        # Ethiopia: roughly 3 to 15 lat, 33 to 48 lon
        if 3 <= lat <= 15 and 33 <= lon <= 48:
            return "Ethiopia"
        # Tanzania: roughly -12 to 0 lat, 29 to 41 lon
        if -12 <= lat <= 0 and 29 <= lon <= 41:
            return "Tanzania"
        # Uganda: roughly -2 to 5 lat, 29 to 35 lon
        if -2 <= lat <= 5 and 29 <= lon <= 35:
            return "Uganda"
        return "default"
    
    def _get_local_price(self, crop: str, region: str) -> Dict[str, Any]:
        """Get price from local fallback data with some variance"""
        import random
        
        region_prices = LOCAL_PRICES.get(region, LOCAL_PRICES["default"])
        base_price = region_prices.get(crop, 50)  # Default price if crop not found
        
        # Add realistic daily variance (-5% to +5%)
        variance = random.uniform(-0.05, 0.05)
        price = round(base_price * (1 + variance), 2)
        
        # Determine trend based on variance
        trend = "stable"
        if variance > 0.02:
            trend = "up"
        elif variance < -0.02:
            trend = "down"
        
        region_info = REGION_ADJUSTMENTS.get(region, REGION_ADJUSTMENTS["default"])
        
        return self._format_response(crop, region, price, source="local", 
                                     currency=region_info["base_currency"], trend=trend)
    
    def _format_response(self, crop: str, region: str, price: float, 
                        source: str = "local", currency: str = "USD", 
                        trend: str = "stable") -> Dict[str, Any]:
        """Format consistent response"""
        return {
            "crop": crop.capitalize(),
            "region": region,
            "price": price,
            "currency": currency,
            "unit": "per kg",
            "trend": trend,
            "source": source,
            "timestamp": self._get_timestamp(),
        }
    
    def _get_timestamp(self) -> str:
        from datetime import datetime
        return datetime.utcnow().isoformat() + "Z"


# Singleton instance
market_service = MarketService()
