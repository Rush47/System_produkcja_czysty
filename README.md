# System produkcja czysty

Minimalny nowy szkielet, bez kopiowania monolitu Bastilla_1_2. Obecnie: HTTP API, czat Ollama z fallback Gemini, prosty interfejs i wskazanie dostawcy. Agenci, terminal, załączniki i synchronizacja nie są jeszcze wdrożone.

## Uruchomienie Codespaces

```bash
npm install
cp .env.example .env
npm start
```

Otwórz port 3000. Dla Ollama potrzebny jest osobny uruchomiony serwer i model `ollama pull llama3.1:8b`. Codespace może mieć za mało pamięci. Klucz `GEMINI_API_KEY` ustaw jako sekret Codespaces, nigdy w repozytorium. Model Gemini jest konfigurowalny przez `GEMINI_MODEL` i wymaga sprawdzenia dostępności w API.

Nie udostępniaj publicznie portu bez autoryzacji. Obecny kod to wersja deweloperska, nie gotowy system produkcyjny. Audyt i plan: issue #1.
