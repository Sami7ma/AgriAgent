import os
from app.antigravity.core import AntigravityAgent

# Mock key for initialization check
if "GEMINI_API_KEY" not in os.environ:
    os.environ["GEMINI_API_KEY"] = "mock_key"

try:
    agent = AntigravityAgent()
    print("Agent initialized successfully.")
except Exception as e:
    print(f"Agent initialization failed: {e}")
