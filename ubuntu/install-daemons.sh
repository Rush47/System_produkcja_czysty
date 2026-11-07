#!/usr/bin/env bash
set -Eeuo pipefail
if [[ "$(id -u)" -ne 0 ]]; then echo "Run with sudo" >&2; exit 1; fi
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
id ubuntu-ai >/dev/null 2>&1 || useradd --system --home-dir /var/lib/ubuntu-ai --create-home --shell /usr/sbin/nologin ubuntu-ai
install -d -o ubuntu-ai -g ubuntu-ai -m 0750 /var/lib/ubuntu-ai/daemons
install -d -m 0750 /etc/ubuntu-ai
install -D -m 0644 "$ROOT/ubuntu/systemd/ubuntu-ai-agent@.service" /etc/systemd/system/ubuntu-ai-agent@.service
systemctl daemon-reload
echo "Install project into /opt/ubuntu-ai with Python venv and requirements before starting."
echo "Then: sudo systemctl enable --now ubuntu-ai-agent@Aria ubuntu-ai-agent@Alex ubuntu-ai-agent@Astyria ubuntu-ai-agent@Aurelius"
