## Ubuntu worker backend (pierwszy etap)

Na Ubuntu 24.04:

```bash
sudo apt-get update && sudo apt-get install -y python3-venv
python3 -m venv .venv
. .venv/bin/activate
pip install -r ubuntu/requirements.txt
uvicorn ubuntu.api:app --host 127.0.0.1 --port 8000
python3 -m unittest discover -s ubuntu/tests
```

Dostępne `/api/health`, `/api/observe`, `/api/tasks`. Obserwacja obejmuje rzeczywiste dane procesów, pamięci i modeli Ollama; pozostałe wymiary uczciwie zwracają `not_connected`. Zadania są zapisywane na dysku. To nie jest jeszcze pełny orkiestrator, czat ani ISO. API nasłuchuje lokalnie; nie wystawiaj bez uwierzytelnienia do Internetu.
