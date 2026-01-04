from datetime import datetime
from app.antigravity.tools import ToolRegistry
from app.schemas import FarmCard
import random

class FarmCardService:
    @staticmethod
    async def generate_card(location: str, crop: str, lat: float = None, lon: float = None) -> FarmCard:
        # Use coordinates if provided for better accuracy (mock logic here)
        display_location = location
        if lat and lon:
            display_location = f"{location} ({lat:.2f}, {lon:.2f})"
        # 1. Get Weather
        weather = ToolRegistry.get_weather(location)
        
        # 2. Get Market
        market = ToolRegistry.get_market_price(crop, location)
        
        # 3. Synthesize "Intelligence" (Simplified for prototype)
        # In a real system, we might use Gemini to write the summaries based on raw data.
        
        weather_summary = f"{weather['temperature']}°C, {weather['condition']}. {weather['forecast']}."
        market_trend_text = f"{crop} is {market['trend']} at {market['price']} {market['currency']}."
        
        # Logic for 'Top Action'
        if weather['condition'] in ["Rainy", "Stormy"]:
            action = "Delay spraying pesticides due to rain."
        elif market['trend'] == "Down":
            action = "Hold sales; prices dropping."
        else:
            action = "Inspect crops for pests."

        return FarmCard(
            date=datetime.now().strftime("%Y-%m-%d"),
            location=display_location,
            weather_summary=weather_summary,
            weather_icon=weather['condition'].lower(),
            market_trend=market_trend_text,
            top_action=action,
            crop_health_score=random.randint(70, 95) # Placeholder for persistent health tracking
        )
