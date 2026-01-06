from datetime import datetime
from app.antigravity.tools import ToolRegistry
from app.schemas import FarmCard
import random

import json
import urllib.request

class FarmCardService:
    @staticmethod
    def _get_city_name(lat: float, lon: float) -> str:
        try:
            url = f"https://nominatim.openstreetmap.org/reverse?format=json&lat={lat}&lon={lon}&zoom=10"
            req = urllib.request.Request(url, headers={
                'User-Agent': 'AgriAgent/1.0',
                'Accept-Language': 'en'
            })
            with urllib.request.urlopen(req, timeout=5) as response:
                data = json.load(response)
                address = data.get('address', {})
                
                # Component extraction
                area = address.get('suburb') or address.get('neighbourhood') or address.get('residential') or ""
                city = address.get('city') or address.get('town') or address.get('village') or address.get('county') or ""
                country = address.get('country') or ""
                
                # Construct parts list
                parts = [p for p in [area, city, country] if p]
                
                if parts:
                    return ", ".join(parts)
                return "Unknown Location"
        except Exception as e:
            print(f"Geocoding error: {e}")
            return f"Lat: {lat:.2f}, Lon: {lon:.2f}"

    @staticmethod
    async def generate_card(location: str, crop: str, lat: float = None, lon: float = None) -> FarmCard:
        # Resolve real location name if coordinates exist
        display_location = location
        if lat and lon:
            real_city = FarmCardService._get_city_name(lat, lon)
            if real_city != "Unknown Location":
                display_location = real_city
            else:
                 display_location = f"{location} ({lat:.2f}, {lon:.2f})"
        
        # 1. Get Weather (using the resolved location name now)
        weather = ToolRegistry.get_weather(display_location)
        
        # 2. Get Market
        market = ToolRegistry.get_market_price(crop, display_location)
        
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
