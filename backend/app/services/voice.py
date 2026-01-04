import os
import google.generativeai as genai
from app.schemas import AgentQueryResponse
import json

class VoiceService:
    def __init__(self):
        if "GEMINI_API_KEY" in os.environ:
            genai.configure(api_key=os.environ["GEMINI_API_KEY"])
        self.model = genai.GenerativeModel('gemini-1.5-flash')

    async def process_voice_query(self, audio_content: bytes, mime_type: str) -> dict:
        """
        Processes a voice query:
        1. Transcribes and Multimodal understanding via Gemini.
        2. Extracts user intent and parameters.
        3. Returns user text and context for the agent.
        """
        
        prompt = """
        You are an interpreter for an agricultural agent.
        The user is speaking in their native language (likely an African dialect or English).
        
        1. Transcribe the audio accurately to English.
        2. Extract the core intent and any entities (crop, location, symptoms).
        3. Detect the original language and urgency.
        
        Return JSON:
        {
            "transcription": "English translation of what they said",
            "original_language": "Swahili",
            "detected_intent": "market_price | weather | diagnosis | general_advice",
            "urgency": "high | medium | low",
            "entities": { ... }
        }
        """
        
        try:
            response = self.model.generate_content([
                prompt,
                {
                    "mime_type": mime_type,
                    "data": audio_content
                }
            ])
            
            text = response.text.replace("```json", "").replace("```", "").strip()
            return json.loads(text)
            
        except Exception as e:
            # Fallback
            return {
                "transcription": "Voice processing failed.",
                "original_language": "unknown",
                "detected_intent": "error",
                "urgency": "low",
                "entities": {},
                "error": str(e)
            }
