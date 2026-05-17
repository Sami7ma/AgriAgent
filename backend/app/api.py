from fastapi import APIRouter, UploadFile, File, Depends
from app.schemas import DiagnoseRequest, DiagnosisResponse, AgentQueryRequest, AgentQueryResponse
from app.antigravity.core import AntigravityAgent
from app.auth import verify_api_key
import logging

router = APIRouter()
agent = AntigravityAgent()
logger = logging.getLogger(__name__)

from app.services.vision import VisionService

vision_service = VisionService()

# ============================================
# SECURITY: File Upload Validation
# ============================================
MAX_FILE_SIZE = 100 * 1024 * 1024  # 100MB
ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp"}
ALLOWED_VIDEO_TYPES = {"video/mp4", "video/quicktime", "video/x-msvideo"}
ALLOWED_MIME_TYPES = ALLOWED_IMAGE_TYPES | ALLOWED_VIDEO_TYPES

@router.post("/analyze/diagnose", response_model=DiagnosisResponse)
async def diagnose_crop(file: UploadFile = File(...), api_key: str = Depends(verify_api_key)):
    # Validate file type
    if file.content_type not in ALLOWED_MIME_TYPES:
        logger.warning(f"Invalid file type: {file.content_type}")
        return {
            "diagnosis": "Invalid file type. Please upload an image (JPG, PNG) or video (MP4).",
            "confidence": 0.0,
            "suggested_actions": []
        }
    
    content = await file.read()
    
    # Validate file size
    if len(content) > MAX_FILE_SIZE:
        logger.warning(f"File too large: {len(content)} bytes (max: {MAX_FILE_SIZE})")
        return {
            "diagnosis": "File is too large. Please upload a file smaller than 100MB.",
            "confidence": 0.0,
            "suggested_actions": []
        }
    
    logger.info(f"Processing file: {file.filename} ({len(content)} bytes, {file.content_type})")
    
    result = await vision_service.analyze_crop(content, file.content_type)

    confidence = result.get("confidence")
    if confidence is not None:
        try:
            confidence = result.get("confidence", 0.0)
            if confidence > 1:
                confidence = confidence / 100.0
            result["confidence"] = confidence
        except Exception as e:
            logger.error(f"Error processing confidence: {e}")
            result["confidence"] = 0.5

    return result


from app.services.voice import VoiceService

voice_service = VoiceService()

@router.post("/agent/interact/voice", response_model=AgentQueryResponse)
async def voice_interaction(file: UploadFile = File(...), api_key: str = Depends(verify_api_key)):
    # 1. Process Voice
    content = await file.read()
    voice_data = await voice_service.process_voice_query(content, file.content_type)
    
    # 2. Extract Text & Context from Voice Analysis
    query_text = voice_data.get("transcription", "")
    context = {
        "original_language": voice_data.get("original_language"),
        "detected_intent": voice_data.get("detected_intent"),
        "urgency": voice_data.get("urgency")
    }
    
    if not query_text or query_text == "Voice processing failed.":
         return {
            "response_text": "I could not understand the audio. Please try again.",
            "suggested_actions": []
        }

    # 3. Agent Reasoning
    agent_result = await agent.reason_and_act(query_text, context)
    
    # 4. Return Response
    return {
        "response_text": agent_result["response"],
        "suggested_actions": agent_result["actions"]
    }

from app.services.farm_card import FarmCardService, FarmCard

@router.post("/agent/query", response_model=AgentQueryResponse)
async def agent_query(request: AgentQueryRequest, api_key: str = Depends(verify_api_key)):

    result = await agent.reason_and_act(
        query=request.query, 
        context=request.context_data,
        history=request.chat_history,
        location=request.location_context
    )
    return {
        "response_text": result["response"],
        "suggested_actions": result["actions"]
    }

@router.get("/artifacts/daily-card", response_model=FarmCard)
async def get_daily_card(location: str = "Nairobi", crop: str = "Maize", lat: float = None, lon: float = None, api_key: str = Depends(verify_api_key)):
    logger.info(f"Daily card requested: location={location}, crop={crop}, lat={lat}, lon={lon}")
    return await FarmCardService.generate_card(location, crop, lat, lon)

# ============================================
# MARKET DATA ENDPOINTS
# ============================================
from app.services.market import MarketService
from pydantic import BaseModel

class MarketPriceResponse(BaseModel):
    crop: str
    price: float
    currency: str
    unit: str = "kg"
    location: str
    timestamp: str

market_service = MarketService()

@router.get("/market/price", response_model=MarketPriceResponse)
async def get_market_price(crop: str = "maize", location: str = "Kenya", api_key: str = Depends(verify_api_key)):
    """Get current market price for a crop in a specific location."""
    logger.info(f"Market price requested: crop={crop}, location={location}")
    
    try:
        price_info = await market_service.get_price(crop.lower(), location)
        
        # Determine currency based on location
        currency_map = {
            "Kenya": "KES",
            "Ethiopia": "ETB",
            "Tanzania": "TZS",
            "Uganda": "UGX",
        }
        currency = currency_map.get(location, "USD")
        
        return {
            "crop": crop.lower(),
            "price": price_info.get("price", 0),
            "currency": currency,
            "unit": "kg",
            "location": location,
            "timestamp": price_info.get("timestamp", "")
        }
    except Exception as e:
        logger.error(f"Error getting market price: {e}")
        return {
            "crop": crop.lower(),
            "price": 0,
            "currency": "USD",
            "unit": "kg",
            "location": location,
            "timestamp": ""
        }
