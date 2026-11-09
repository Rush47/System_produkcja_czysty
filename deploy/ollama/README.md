# Ollama 8B — AI Studio backend

This deployment uses the official `ollama/ollama` Docker image and downloads the model previously configured in the AI_System_Linux project: `thox-ai/thoxopen-8b-heretic:q4_k_m`. Availability and model provenance must be verified when pulling.

Run on a Linux host with Docker Compose:

```bash
bash deploy/ollama/setup.sh
```

To choose another 8B model:

```bash
OLLAMA_MODEL='your-model:tag' bash deploy/ollama/setup.sh
```

Check locally: `curl -fsS http://127.0.0.1:11434/api/tags`

The Ollama port is bound to localhost only. Google AI Studio's hosted browser preview **cannot** access the host's localhost. To connect the app, use a secure, authenticated HTTPS backend/proxy and configure the server-side `OLLAMA_BASE_URL` to the reachable endpoint; never publish port 11434 directly without authentication. `OLLAMA_MODEL` must match the pulled model. `GEMINI_MODEL` is configured separately if fallback is needed.

This package does not alter the existing GUI or claim the model is already running. The host must have sufficient RAM and storage.
