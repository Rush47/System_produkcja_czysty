#!/usr/bin/env bash
set -Eeuo pipefail
if [[ "$(uname -s)" != Linux ]]; then echo "Requires Linux" >&2; exit 1; fi
if command -v ollama >/dev/null 2>&1; then echo "Ollama already installed"; exit 0; fi
echo "Install Ollama using the official Linux package instructions: https://ollama.com/download/linux"
echo "No unverified remote shell scripts are executed automatically."
exit 2
