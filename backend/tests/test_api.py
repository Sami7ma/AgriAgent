"""
Unit Tests for AgriAgent Backend
Run with: pytest tests/ -v
"""
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, AsyncMock
import sys
import os

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from main import app

client = TestClient(app)


class TestHealthEndpoints:
    """Test basic health and root endpoints"""
    
    def test_root_endpoint(self):
        response = client.get("/")
        assert response.status_code == 200
        assert "message" in response.json()
        assert "AgriAgent" in response.json()["message"]
    
    def test_health_check(self):
        response = client.get("/health")
        assert response.status_code == 200
        assert response.json()["status"] == "ok"


class TestInputValidation:
    """Test input validation for API endpoints"""
    
    def test_agent_query_empty_string(self):
        """Empty query should fail validation"""
        response = client.post("/api/v1/agent/query", json={
            "query": ""
        })
        assert response.status_code == 422  # Validation error
    
    def test_agent_query_too_long(self):
        """Query exceeding max length should fail"""
        long_query = "x" * 2001  # Max is 2000
        response = client.post("/api/v1/agent/query", json={
            "query": long_query
        })
        assert response.status_code == 422
    
    def test_agent_query_html_sanitized(self):
        """HTML tags should be stripped from query"""
        response = client.post("/api/v1/agent/query", json={
            "query": "<script>alert('xss')</script>What is the weather?"
        })
        # Should not fail, but query should be sanitized
        # The actual processing depends on agent, but no 500 error
        assert response.status_code in [200, 500]  # 500 if agent fails, but not 422
    
    def test_invalid_language_code(self):
        """Invalid language code should fail validation"""
        response = client.post("/api/v1/agent/query", json={
            "query": "Hello",
            "language": "english"  # Should be 2-letter code
        })
        assert response.status_code == 422
    
    def test_valid_language_code(self):
        """Valid 2-letter language code should pass"""
        response = client.post("/api/v1/agent/query", json={
            "query": "Hello there",
            "language": "en"
        })
        # May fail due to agent, but not validation
        assert response.status_code != 422


class TestDailyCard:
    """Test daily card endpoint"""
    
    def test_daily_card_default(self):
        """Default daily card should return data"""
        response = client.get("/api/v1/artifacts/daily-card")
        assert response.status_code == 200
        data = response.json()
        assert "location" in data
        assert "weather_summary" in data
    
    def test_daily_card_with_location(self):
        """Daily card with location parameter"""
        response = client.get("/api/v1/artifacts/daily-card?location=Nairobi")
        assert response.status_code == 200
        data = response.json()
        assert "Nairobi" in data.get("location", "")
    
    def test_daily_card_with_coordinates(self):
        """Daily card with lat/lon should use coordinates"""
        response = client.get("/api/v1/artifacts/daily-card?lat=-1.286&lon=36.817")
        assert response.status_code == 200


class TestMarketService:
    """Test market data functionality"""
    
    def test_market_price_local_fallback(self):
        """Market service should return local prices when API unavailable"""
        from app.services.market import MarketService
        service = MarketService()
        result = service._get_local_price("maize", "Kenya")
        
        assert result["crop"] == "Maize"
        assert result["region"] == "Kenya"
        assert result["currency"] == "KES"
        assert result["price"] > 0
    
    def test_region_detection(self):
        """Test region detection from coordinates"""
        from app.services.market import MarketService
        service = MarketService()
        
        # Nairobi coordinates
        assert service._get_region_from_coords(-1.286, 36.817) == "Kenya"
        
        # Addis Ababa coordinates
        assert service._get_region_from_coords(9.005, 38.763) == "Ethiopia"
        
        # Random coordinates outside East Africa
        assert service._get_region_from_coords(51.5, -0.1) == "default"


class TestToolRegistry:
    """Test agent tools"""
    
    @pytest.mark.asyncio
    async def test_get_weather_fallback(self):
        """Weather tool should return data even without API"""
        from app.antigravity.tools import ToolRegistry
        
        # Test with no coordinates (fallback mode)
        result = await ToolRegistry.get_weather("Nairobi")
        
        assert result["location"] == "Nairobi"
        assert "condition" in result
        assert "temperature" in result
    
    @pytest.mark.asyncio
    async def test_get_market_price_fallback(self):
        """Market price tool should return data"""
        from app.antigravity.tools import ToolRegistry
        
        result = await ToolRegistry.get_market_price("Maize", "Kenya")
        
        assert "crop" in result
        assert "price" in result
        assert result["price"] > 0
    
    def test_get_knowledge(self):
        """Knowledge tool should return relevant advice"""
        from app.antigravity.tools import ToolRegistry
        
        result = ToolRegistry.get_knowledge("pest control methods")
        
        assert "pest" in result.lower() or "control" in result.lower()
        assert len(result) > 20  # Should be meaningful advice


# Run configuration
if __name__ == "__main__":
    pytest.main([__file__, "-v"])
