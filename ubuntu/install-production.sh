#!/usr/bin/env bash
# Install the Ubuntu AI backend and five local observation daemons.
# Optional Ollama installation: INSTALL_OLLAMA=1 sudo bash ubuntu/install-production.sh
set -Eeuo pipefail
if (( EUID != 0 )); then echo "Run with sudo: sudo bash ubuntu/install-production.sh" >&2; exit 1; fi
. /etc/os-release
if [[ "${ID:-}" != "ubuntu" ]]; then echo "Ubuntu required" >&2; exit 1; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip ca-certificates curl
install -d -o root -g root -m 0755 /opt/ubuntu-ai
cp -a "$ROOT/ubuntu" /opt/ubuntu-ai/
python3 -m venv /opt/ubuntu-ai/.venv
/opt/ubuntu-ai/.venv/bin/python -m pip install --disable-pip-version-check -r /opt/ubuntu-ai/ubuntu/requirements.txt
install -d -o root -g root -m 0700 /var/lib/ubuntu-ai/daemons /etc/ubuntu-ai
if [[ ! -e /etc/ubuntu-ai/daemon.env ]]; then
  printf 'OLLAMA_BASE_URL=http://127.0.0.1:11434\nOLLAMA_MODEL=llama3.1:8b\nDAEMON_DATA_DIR=/var/lib/ubuntu-ai/daemons\n' > /etc/ubuntu-ai/daemon.env
  chmod 0600 /etc/ubuntu-ai/daemon.env
fi
install -m 0644 /opt/ubuntu-ai/ubuntu/systemd/ubuntu-ai-agent@.service /etc/systemd/system/ubuntu-ai-agent@.service
install -m 0644 /opt/ubuntu-ai/ubuntu/systemd/ubuntu-ai-api.service /etc/systemd/system/ubuntu-ai-api.service
systemctl daemon-reload
for agent in Aria Alex Astyria Aurelius System; do
  systemctl enable --now "ubuntu-ai-agent@${agent}.service"
done
systemctl enable --now ubuntu-ai-api.service
if [[ "${INSTALL_OLLAMA:-0}" == "1" ]]; then
  if ! command -v ollama >/dev/null 2>&1; then
    echo "Install Ollama from its official Linux instructions: https://ollama.com/download/linux"
    echo "Automatic execution of a remote installer is intentionally disabled."
  else
    systemctl enable --now ollama.service || true
    ollama pull "${OLLAMA_MODEL:-llama3.1:8b}"
  fi
fi
echo "Ubuntu AI installed. Local API: http://127.0.0.1:8000/api/health"
echo "Agent System uses Ollama after the Ollama service and selected model are installed."
echo "Optional Linux admin account: sudo bash ubuntu/create-system-user.sh"
