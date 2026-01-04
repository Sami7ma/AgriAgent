from pydantic import BaseModel, Field
from typing import List, Optional

class DiagnoseRequest(BaseModel):
    # In a real app, this might accept a file upload, 
    # but for JSON metadata or initial checks we might use this.
    lat: float
    lon: float
    notes: Optional[str] = None

class DiagnosisResponse(BaseModel):
    crop: str
    issue: str
    confidence: float
    affected_area: str
    severity: str
    actions: List[str]

class AgentQueryRequest(BaseModel):
    query: str
    context_data: Optional[dict] = None
    language: str = "en"

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

