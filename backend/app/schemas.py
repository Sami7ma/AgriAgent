from pydantic import BaseModel, Field, field_validator
from typing import List, Optional
import re

class DiagnoseRequest(BaseModel):
    # In a real app, this might accept a file upload, 
    # but for JSON metadata or initial checks we might use this.
    lat: float = Field(..., ge=-90, le=90, description="Latitude must be between -90 and 90")
    lon: float = Field(..., ge=-180, le=180, description="Longitude must be between -180 and 180")
    notes: Optional[str] = Field(None, max_length=1000, description="Optional notes, max 1000 chars")

class DiagnosisResponse(BaseModel):
    crop: str
    issue: str
    confidence: float = Field(..., ge=0, le=1)
    affected_area: str
    severity: str
    actions: List[str]

class AgentQueryRequest(BaseModel):
    query: str = Field(..., min_length=1, max_length=2000, description="User query, max 2000 chars")
    context_data: Optional[dict] = None
    chat_history: List[dict] = Field(default=[], max_length=50)  # Limit history size
    location_context: Optional[dict] = None
    language: str = Field(default="en", pattern="^[a-z]{2}$")  # ISO language code
    
    @field_validator('query')
    @classmethod
    def sanitize_query(cls, v: str) -> str:
        # Remove potential script injection
        v = re.sub(r'<[^>]*>', '', v)  # Remove HTML tags
        return v.strip()

class AgentQueryResponse(BaseModel):
    response_text: str
    audio_url: Optional[str] = None
    suggested_actions: List[str] = []

class FarmCard(BaseModel):
    date: str
    location: str
    weather_summary: str
    weather_icon: str # e.g., "sunny", "rain"
    market_trend: str
    top_action: str
    crop_health_score: int # 0-100

