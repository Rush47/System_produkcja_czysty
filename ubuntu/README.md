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

Agent **System** jest piątym, niezależnym agentem na liście (nie kontem Linux). Docelowy silnik: lokalna Ollama; obecny rejestr nie potwierdza jeszcze sesji inferencji.\n
## Instalacja na Ubuntu (systemd)

W sklonowanym repozytorium:

```bash
sudo bash ubuntu/install-production.sh
sudo bash ubuntu/create-system-user.sh
```

Druga komenda tworzy **konto Linux System** z prawem sudo i prosi o hasło. Osobno istnieje **agent AI System**. Wszystkich pięć daemonów uruchamia systemd, ale obecnie realizują obserwację systemu, a nie samodzielną inferencję agentów źródłowych.

Aby aktywować odpowiedzi agenta System, zainstaluj Ollamę zgodnie z https://ollama.com/download/linux, następnie:

```bash
ollama pull dolphin3:8b
sudo systemctl restart ubuntu-ai-api.service
curl http://127.0.0.1:8000/api/health
curl -sS -X POST http://127.0.0.1:8000/api/agents/system/chat -H 'Content-Type: application/json' -d '{"message":"Cześć, System!"}'
sudo systemctl status ubuntu-ai-api.service
```

Domyślny model `dolphin3:8b` nie jest wariantem uncensored. Jeśli chcesz inny model, pobierz go w Ollamie i ustaw `OLLAMA_MODEL` w `/etc/ubuntu-ai/daemon.env`. Instalator nie uruchamia niezweryfikowanego zdalnego skryptu instalacyjnego. Lokalny endpoint API nie ma uwierzytelniania: **nie wystawiaj portu 8000 do Internetu**.

Uwaga: konfiguracja i testy zostały zapisane w repozytorium, ale nie potwierdzono ich działania na docelowej maszynie.

Model domyślny: **dolphin3:8b** (Dolphin 3.0, uncensored). Instalacja modelu: `ollama pull dolphin3:8b`.\n
## Lokalna konsola Python + Bash + root

Uruchom w interaktywnym terminalu Ubuntu:

```bash
python3 ubuntu/python-console.py
```

Przykłady: `shell("pwd")`, `shell("id", root=True)`, `root_shell()`.
Polecenia z `root=True` i `root_shell()` używają sudo; wymagają autoryzacji. Nie uruchamiaj tej konsoli jako usługi sieciowej ani nie udostępniaj jej agentom bez kontroli dostępu. Konsola nie jest jeszcze wbudowana w GUI.
