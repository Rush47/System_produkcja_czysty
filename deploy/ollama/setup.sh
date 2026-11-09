#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
MODEL="${OLLAMA_MODEL:-thox-ai/thoxopen-8b-heretic:q4_k_m}"
command -v docker >/dev/null || { echo "Docker is required"; exit 1; }
docker compose up -d ollama
echo "Waiting for Ollama..."
for i in $(seq 1 60); do
  if docker compose exec -T ollama ollama list >/dev/null 2>&1; then break; fi
  sleep 2
done
docker compose exec -T ollama ollama pull "$MODEL"
docker compose exec -T ollama ollama show "$MODEL"
echo "Ollama ready on 127.0.0.1:11434, model: $MODEL"
echo "Set OLLAMA_BASE_URL to a server-reachable URL; localhost in browser AI Studio is NOT the remote server."
