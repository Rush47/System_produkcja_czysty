#!/usr/bin/env bash
set -Eeuo pipefail
MODEL="${OLLAMA_MODEL:-llama3.1:8b}"
if [[ "$(uname -s)" != "Linux" ]]; then echo "Linux required" >&2; exit 1; fi
if ! command -v ollama >/dev/null 2>&1; then
  echo "Ollama is not installed. Install it from the official instructions: https://ollama.com/download/linux"
  echo "This script intentionally does not execute a remote shell installer automatically."
  exit 2
fi
if ! curl --fail --silent --max-time 3 "${OLLAMA_BASE_URL:-http://127.0.0.1:11434}/api/version" >/dev/null; then
  echo "Ollama daemon is not reachable. Start it with: ollama serve" >&2
  exit 3
fi
echo "Pulling model: $MODEL (large download; verify available RAM/disk)"
ollama pull "$MODEL"
echo "Ready: $MODEL"
