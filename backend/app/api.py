from fastapi import APIRouter, UploadFile, File
from app.schemas import DiagnoseRequest, DiagnosisResponse, AgentQueryRequest, AgentQueryResponse
from app.antigravity.core import AntigravityAgent

router = APIRouter()
agent = AntigravityAgent()

from app.services.vision import VisionService

vision_service = VisionService()

@router.post("/analyze/diagnose", response_model=DiagnosisResponse)
async def diagnose_crop(file: UploadFile = File(...)):
    print("DEBUG: file received")
    print("DEBUG: filename =", file.filename)
    print("DEBUG: content_type =", file.content_type)

    content = await file.read()
    print("DEBUG: file size =", len(content))

    result = await vision_service.analyze_crop(content, file.content_type)
    print("DEBUG: vision result =", result)

    confidence = result.get("confidence")
    if confidence is not None:
        try:
            confidence = float(confidence)
            if confidence > 1:
                confidence = confidence / 100.0
            result["confidence"] = confidence
        except Exception:
            result["confidence"] = 0.5

    return result


from app.services.voice import VoiceService

voice_service = VoiceService()

@router.post("/agent/interact/voice", response_model=AgentQueryResponse)
async def voice_interaction(file: UploadFile = File(...)):
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
async def agent_query(request: AgentQueryRequest):

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
async def get_daily_card(location: str = "Nairobi", crop: str = "Maize", lat: float = None, lon: float = None):
    print(f"DEBUG: get_daily_card hit. lat={lat}, lon={lon}")
    return await FarmCardService.generate_card(location, crop, lat, lon)

