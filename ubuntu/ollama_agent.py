"""Real local Ollama inference for the independent System agent."""
from __future__ import annotations
import os
import httpx

class OllamaUnavailable(RuntimeError):
    pass

async def chat(message: str, model: str | None = None) -> dict:
    if not message.strip():
        raise ValueError("Message cannot be empty")
    if len(message) > 32000:
        raise ValueError("Message exceeds 32000 characters")
    base = os.getenv("OLLAMA_BASE_URL", "http://127.0.0.1:11434").rstrip("/")
    chosen = model or os.getenv("OLLAMA_MODEL", "dolphin3:8b")
    payload = {"model": chosen, "messages": [{"role": "user", "content": message}], "stream": False}
    try:
        async with httpx.AsyncClient(timeout=httpx.Timeout(180.0, connect=5.0), trust_env=False) as client:
            response = await client.post(base + "/api/chat", json=payload)
            response.raise_for_status()
            result = response.json()
    except (httpx.HTTPError, ValueError) as exc:
        raise OllamaUnavailable(f"Ollama request failed: {type(exc).__name__}") from exc
    answer = result.get("message", {}).get("content")
    if not isinstance(answer, str):
        raise OllamaUnavailable("Ollama returned no message content")
    return {"agent": "System", "provider": "ollama", "model": result.get("model", chosen),
            "response": answer, "done": result.get("done", False)}
