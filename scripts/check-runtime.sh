#!/usr/bin/env bash
set -euo pipefail
PORT="${PORT:-3000}"
echo "Node: $(node --version)"
echo "npm: $(npm --version)"
echo "App health:"
curl --fail --silent --show-error "http://127.0.0.1:$PORT/api/health"
echo
echo "Ollama health:"
curl --fail --silent --show-error --max-time 3 "${OLLAMA_BASE_URL:-http://127.0.0.1:11434}/api/version" || true
echo
