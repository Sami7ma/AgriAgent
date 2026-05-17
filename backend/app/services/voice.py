import os
import google.generativeai as genai
from app.schemas import AgentQueryResponse
import json
import logging

logger = logging.getLogger(__name__)

class VoiceService:
    def __init__(self):
        if "GEMINI_API_KEY" in os.environ:
            genai.configure(api_key=os.environ["GEMINI_API_KEY"])
            logger.info("Gemini API configured for voice processing")
        else:
            logger.warning("GEMINI_API_KEY not found for voice service")
        self.model = genai.GenerativeModel('gemini-1.5-flash')

    async def process_voice_query(self, audio_content: bytes, mime_type: str) -> dict:
        """
        Processes a voice query:
        1. Transcribes and provides multimodal understanding via Gemini.
        2. Extracts user intent and parameters.
        3. Returns user text and context for the agent.
        
        Args:
            audio_content: Audio file bytes
            mime_type: MIME type of audio (e.g., audio/mp3, audio/wav)
            
        Returns:
            Dictionary with transcription, language, intent, and urgency
        """
        
        prompt = """
        You are an interpreter for an agricultural agent.
        The user is speaking in their native language (likely an African dialect or English).
        
        1. Transcribe the audio accurately to English.
        2. Extract the core intent and any entities (crop, location, symptoms).
        3. Detect the original language and urgency.
        
        Return JSON (no markdown):
        {
            "transcription": "English translation of what they said",
            "original_language": "Swahili",
            "detected_intent": "market_price | weather | diagnosis | general_advice",
            "urgency": "high | medium | low",
            "entities": {}
        }
        """
        
        try:
            logger.debug(f"Processing voice: {len(audio_content)} bytes, {mime_type}")
            response = self.model.generate_content([
                prompt,
                {
                    "mime_type": mime_type,
                    "data": audio_content
                }
            ])
            
            text = response.text.replace("```json", "").replace("```", "").strip()
            result = json.loads(text)
            logger.info(f"Voice processed: {result.get('detected_intent')}")
            return result
            
        except Exception as e:
            # Fallback
            logger.error(f"Voice processing error: {e}", exc_info=True)
            return {
                "transcription": "Voice processing failed. Please try again.",
                "original_language": "unknown",
                "detected_intent": "error",
                "urgency": "low",
                "entities": {}
            }
