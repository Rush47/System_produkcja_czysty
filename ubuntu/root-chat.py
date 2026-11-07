#!/usr/bin/env python3
"""Local root chat terminal. Start with sudo from an interactive Ubuntu terminal.

The LLM generates a shell command and the session runs it as root automatically.
Never expose this program through HTTP or a remotely reachable API.
"""
import asyncio
import json
import os
from pathlib import Path
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from ubuntu.ollama_agent import chat

SYSTEM_PROMPT = """You translate the user's Polish or English system administration request
into a single Bash command for an Ubuntu machine. Respond ONLY with a JSON object
with exactly one string field named "command". Do not include markdown.
The command will execute on the real machine as root. If the user is asking a
question rather than requesting an action, produce a read-only command to inspect
the relevant system state. Do not claim the command has already run.
User request:
"""

async def main():
    if not (sys.stdin.isatty() and sys.stdout.isatty()):
        raise SystemExit("Interactive local terminal required")
    if os.geteuid() != 0:
        raise SystemExit("Run with sudo: sudo python3 ubuntu/root-chat.py")
    print("System root chat / Ollama dolphin3:8b. Type /exit to quit.")
    print("Commands execute automatically with root privileges on this machine.")
    while True:
        try:
            request = input("\nSystem(root)> ").strip()
        except (EOFError, KeyboardInterrupt):
            print()
            break
        if request in {"/exit", "/quit"}:
            break
        if not request:
            continue
        try:
            result = await chat(SYSTEM_PROMPT + request)
            raw = result["response"].strip()
            if raw.startswith("```"):
                raw = "\n".join(raw.splitlines()[1:-1])
            command = json.loads(raw)["command"]
            if not isinstance(command, str) or not command.strip():
                raise ValueError("Model did not produce a command")
            print(f"\n[Ollama {result['model']}] $ {command}", flush=True)
            proc = subprocess.run(["/bin/bash", "-lc", command], check=False)
            print(f"[exit code: {proc.returncode}]", flush=True)
        except Exception as exc:
            print(f"[error] {type(exc).__name__}: {exc}", file=sys.stderr)

if __name__ == "__main__":
    asyncio.run(main())
