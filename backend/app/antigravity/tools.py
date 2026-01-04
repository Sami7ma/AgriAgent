import random
from typing import Dict, Any

class ToolRegistry:
    @staticmethod
    def get_weather(location: str) -> Dict[str, Any]:
        """
        Get the current weather and forecast for a given location.
        """
        # Mock weather logic
        conditions = ["Sunny", "Cloudy", "Rainy", "Stormy", "Drought"]
        condition = random.choice(conditions)
        temp = random.randint(20, 35)
        rain_chance = random.randint(0, 100)
        
        return {
            "location": location,
            "condition": condition,
            "temperature": temp,
            "rain_chance": rain_chance,
            "forecast": "Rain expected in 2 days" if rain_chance < 50 else "Rain continues"
        }

    @staticmethod
    def get_market_price(crop: str, region: str) -> Dict[str, Any]:
        """
        Get the current market price for a specified crop in a region.
        """
        # Mock market logic
        base_price = 100
        volatility = random.randint(-20, 20)
        price = base_price + volatility
        
        return {
            "crop": crop,
            "region": region,
            "price": price,
            "currency": "KES", # Kenyan Shilling context
            "trend": "Up" if volatility > 0 else "Down"
        }
    
    @staticmethod
    def get_knowledge(query: str) -> str:
        """
        Retrieve agricultural knowledge about a specific topic.
        """
        return f"General agronomy advice on {query}: Rotate crops every season to maintain soil health."

