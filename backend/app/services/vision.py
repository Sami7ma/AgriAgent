import os
import google.generativeai as genai
from app.schemas import DiagnosisResponse
import json

# Configure Gemini
# Ensure GEMINI_API_KEY is set in environment or .env
if "GEMINI_API_KEY" in os.environ:
    key = os.environ["GEMINI_API_KEY"]
    print(f"DEBUG: Found GEMINI_API_KEY. Length: {len(key)}, Start: {key[:4]}...")
    genai.configure(api_key=key)
else:
    print("DEBUG: GEMINI_API_KEY not found in environment variables.")

class VisionService:
    def __init__(self):
        # Using 'gemini-flash-latest' which typically maps to the stable 1.5 Flash model
        # effectively avoiding the strict quotas of 2.0/experimental versions.
        self.model = genai.GenerativeModel('gemini-flash-latest')

    async def analyze_crop(self, file_content: bytes, mime_type: str) -> DiagnosisResponse:
        """
        Analyzes a crop image/video using Gemini Vision.
        """
        prompt = """
        You are an expert agronomist. Analyze this video/image of a crop. 
        Identify the crop, any visible diseases, pests, or issues.
        Provide a structured diagnosis.
        
        Return pure JSON with the following keys:
        - crop: string
        - issue: string
        - confidence: float (0-100)
        - affected_area: string (description of where the issue is)
        - severity: string (low, medium, high)
        - actions: list of strings (immediate recommendations)
        
        Do not include markdown formatting like ```json.
        """
        
        # In a real app, we might need to handle video upload to File API for large videos.
        # For small clips or images, passing data directly might work depending on SDK version.
        # Alternatively, we save to temp file and upload.
        
        # For prototype, let's assume image or small video bytes.
        # We need to construct the content part correctly.
        
        # Note: 'gemini-1.5-flash' supports video.
        
        try:
            response = self.model.generate_content([
                prompt,
                {
                    "mime_type": mime_type,
                    "data": file_content
                }
            ])
            
            # Simple parsing
            text = response.text.replace("```json", "").replace("```", "").strip()
            data = json.loads(text)
            
            return DiagnosisResponse(**data)
            
        except Exception as e:
            # Fallback for error handling
            print(f"Error calling Gemini: {e}")
            return DiagnosisResponse(
                crop="Unknown",
                issue=f"Analysis failed: {str(e)}",
                confidence=0.0,
                affected_area="N/A",
                severity="unknown",
                actions=["Retry analysis"]
            )
