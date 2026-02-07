import random
from typing import Dict, Any
import httpx
import os
import logging

logger = logging.getLogger(__name__)

class ToolRegistry:
    """
    Tools available to the Antigravity Agent.
    Each tool is exposed to Gemini for function calling.
    """
    
    @staticmethod
    async def get_weather(location: str, lat: float = None, lon: float = None) -> Dict[str, Any]:
        """
        Get the current weather and forecast for a given location.
        Uses Open-Meteo API for real data when coordinates provided.
        """
        try:
            if lat is not None and lon is not None:
                # Real weather from Open-Meteo
                async with httpx.AsyncClient(timeout=10.0) as client:
                    url = f"https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current_weather=true&daily=precipitation_sum&timezone=auto"
                    response = await client.get(url)
                    data = response.json()
                    
                    current = data.get("current_weather", {})
                    daily = data.get("daily", {})
                    
                    # Map weather code to condition
                    code = current.get("weathercode", 0)
                    condition = ToolRegistry._weather_code_to_condition(code)
                    
                    # Calculate rain chance from precipitation forecast
                    precip = daily.get("precipitation_sum", [0])
                    rain_chance = min(100, int(sum(precip[:3]) * 10))  # Next 3 days
                    
                    return {
                        "location": location,
                        "condition": condition,
                        "temperature": current.get("temperature", 25),
                        "rain_chance": rain_chance,
                        "forecast": f"Expected precipitation: {sum(precip[:3]):.1f}mm in next 3 days",
                        "source": "open-meteo"
                    }
        except Exception as e:
            logger.warning(f"Weather API error: {e}. Using fallback.")
        
        # Fallback to mock data
        conditions = ["Sunny", "Cloudy", "Rainy", "Stormy", "Clear"]
        condition = random.choice(conditions)
        temp = random.randint(20, 35)
        rain_chance = random.randint(0, 100)
        
        return {
            "location": location,
            "condition": condition,
            "temperature": temp,
            "rain_chance": rain_chance,
            "forecast": "Rain expected in 2 days" if rain_chance > 50 else "Dry conditions expected",
            "source": "fallback"
        }
    
    @staticmethod
    def _weather_code_to_condition(code: int) -> str:
        """Map WMO weather codes to readable conditions"""
        if code == 0:
            return "Clear"
        elif code in [1, 2, 3]:
            return "Partly Cloudy"
        elif code in [45, 48]:
            return "Foggy"
        elif code in [51, 53, 55, 56, 57]:
            return "Drizzle"
        elif code in [61, 63, 65, 66, 67]:
            return "Rainy"
        elif code in [71, 73, 75, 77]:
            return "Snowy"
        elif code in [80, 81, 82]:
            return "Showers"
        elif code in [95, 96, 99]:
            return "Thunderstorm"
        return "Unknown"

    @staticmethod
    async def get_market_price(crop: str, region: str, lat: float = None, lon: float = None) -> Dict[str, Any]:
        """
        Get the current market price for a specified crop in a region.
        Uses real market data when available.
        """
        try:
            from app.services.market import market_service
            return await market_service.get_price(crop, region, lat, lon)
        except Exception as e:
            logger.warning(f"Market service error: {e}. Using fallback.")
        
        # Fallback to basic mock
        base_prices = {
            "maize": 45, "wheat": 55, "coffee": 350, "teff": 120, "rice": 80
        }
        base_price = base_prices.get(crop.lower(), 50)
        volatility = random.randint(-10, 10)
        price = base_price + volatility
        
        return {
            "crop": crop,
            "region": region,
            "price": price,
            "currency": "KES",
            "trend": "Up" if volatility > 0 else "Down",
            "source": "fallback"
        }
    
    @staticmethod
    def get_knowledge(query: str) -> str:
        """
        Retrieve agricultural knowledge about a specific topic.
        In production, this would connect to a knowledge base or vector DB.
        """
        # Common agricultural advice based on keywords
        knowledge_base = {
            "pest": "For pest control, consider integrated pest management (IPM). Use neem-based pesticides for organic farming. Monitor fields regularly for early detection.",
            "disease": "For plant diseases, ensure proper spacing for air circulation. Remove infected plants immediately. Use disease-resistant varieties when possible.",
            "irrigation": "Efficient irrigation depends on crop type and soil. Drip irrigation saves 30-50% water. Water early morning to reduce evaporation.",
            "fertilizer": "Apply fertilizers based on soil tests. Over-fertilization harms soil health. Consider organic options like compost and manure.",
            "harvest": "Harvest timing affects quality and price. Monitor crop maturity indicators. Store properly to prevent post-harvest losses.",
            "soil": "Healthy soil is key to good yields. Rotate crops to maintain nutrients. Add organic matter regularly.",
        }
        
        query_lower = query.lower()
        for keyword, advice in knowledge_base.items():
            if keyword in query_lower:
                return advice
        
        return f"General agricultural advice for '{query}': Maintain good farming practices, rotate crops, and consult local extension officers for specific guidance."
