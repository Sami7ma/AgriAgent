import os
import google.generativeai as genai
from app.antigravity.tools import ToolRegistry
import logging

logger = logging.getLogger(__name__)

class AntigravityAgent:
    def __init__(self):
        if "GEMINI_API_KEY" in os.environ:
            genai.configure(api_key=os.environ["GEMINI_API_KEY"])
        
        # Define the available tools for Gemini
        self.tools_config = [
            ToolRegistry.get_weather,
            ToolRegistry.get_market_price,
            ToolRegistry.get_knowledge
        ]
        
        # Using 'gemini-flash-latest' to match vision service and ensure access
        self.model = genai.GenerativeModel(
            'gemini-flash-latest',
            tools=self.tools_config
        )
        
        # Chat session could be persisted, but for now we create new per request or manage history
        # For simplicity in this API, we might not maintain long history yet.
    
    async def reason_and_act(self, query: str, context: dict, history: list = [], location: dict = None) -> dict:
        """
        Executes the agentic loop with Memory and Context.
        """
        
        # 1. Build System Context
        system_prompt = "You are AgriAgent, an expert agricultural AI assistant.\n"
        
        if location:
            system_prompt += f"User Location: {location.get('city', 'Unknown')}, {location.get('country', '')} (Lat: {location.get('lat')}, Lon: {location.get('lon')}).\n"
            system_prompt += "Use this location for weather and market queries.\n"
            
        system_prompt += f"Current Context: {context}.\n"
        
        # 2. Build Conversation History
        history_str = ""
        for msg in history[-10:]: # Keep last 10 turns to avoid token limits
            role = "User" if msg.get("role") == "user" else "AgriAgent"
            content = msg.get("text", "")
            history_str += f"{role}: {content}\n"
            
        full_prompt = f"{system_prompt}\n\nConversation History:\n{history_str}\nUser: {query}\nAgriAgent:"
        
        try:
            # We use chat for multi-turn tool interaction (but here we effectively manually manage history for stateless API)
            chat = self.model.start_chat(enable_automatic_function_calling=True)
            response = chat.send_message(full_prompt)
            
            # Extract text response
            final_text = response.text
            
            # Extract which tools were used (heuristic, or if response object has history)
            # In automatic mode, we just see the final answer.
            # To recommend actions, we can parse the response or ask Gemini to output actions explicitly.
            
            # Use another call or parse structured actions if we want structured output.
            # For now, return text.
            
            # Heuristic for suggested actions based on text
            actions = []
            if "market" in final_text.lower():
                actions.append("Check market trends again later")
            if "weather" in final_text.lower():
                actions.append("Prepare for weather changes")
            
            return {
                "response": final_text,
                "actions": actions
            }
            
        except Exception as e:
            logger.error(f"Agent error: {e}")
            return {
                "response": "I'm having trouble thinking right now. Please try again.",
                "actions": []
            }

