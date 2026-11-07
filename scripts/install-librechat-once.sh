#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="${LIBRECHAT_HOME:-$HOME/.local/share/ubuntu-ai/librechat}"
MARKER="$ROOT/.ubuntu-ai-installed"
command -v git >/dev/null || { echo "Install git first"; exit 1; }
command -v docker >/dev/null || { echo "Install Docker first"; exit 1; }
docker compose version >/dev/null || { echo "Docker Compose plugin required"; exit 1; }
if [ -f "$MARKER" ]; then echo "LibreChat already installed. Use scripts/librechat.sh for management."; exit 0; fi
if [ ! -d "$ROOT/.git" ]; then
 mkdir -p "$(dirname "$ROOT")"
 git clone https://github.com/danny-avila/LibreChat.git "$ROOT"
fi
if [ ! -f "$ROOT/.env" ]; then
 cp "$ROOT/.env.example" "$ROOT/.env"
 chmod 600 "$ROOT/.env"
fi
touch "$MARKER"
echo "LibreChat prepared at $ROOT."
echo "Review $ROOT/.env and configure secrets, then run: bash scripts/librechat.sh start"
echo "For automatic startup, configure the Docker daemon to start on boot; compose services need suitable restart policies."
