const timeout = () => Math.min(120000, Math.max(1000, Number(process.env.LLM_TIMEOUT_MS || 30000)));
async function postJson(url, payload, headers = {}) {
  const response = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json', ...headers }, body: JSON.stringify(payload), signal: AbortSignal.timeout(timeout()) });
  const data = await response.json();
  if (!response.ok) throw new Error('Model API HTTP ' + response.status);
  return data;
}
export async function generateReply(message) {
  const primary = process.env.OLLAMA_MODEL || 'llama3.1:8b';
  const base = (process.env.OLLAMA_BASE_URL || 'http://127.0.0.1:11434').replace(/\\/$/, '');
  let firstError;
  try {
    const data = await postJson(base + '/api/chat', { model: primary, messages: [{ role: 'user', content: message }], stream: false });
    const text = data.message?.content;
    if (typeof text !== 'string' || !text.trim()) throw new Error('Ollama zwróciła pustą odpowiedź');
    return { text, provider: 'ollama', model: primary, fallback: false };
  } catch (error) { firstError = error; }
  const key = process.env.GEMINI_API_KEY;
  if (!key) throw new Error('Ollama niedostępna, Gemini fallback nie jest skonfigurowany');
  const model = process.env.GEMINI_MODEL || 'gemini-2.5-flash-lite';
  try {
    const data = await postJson('https://generativelanguage.googleapis.com/v1beta/models/' + encodeURIComponent(model) + ':generateContent', { contents: [{ parts: [{ text: message }] }] }, { 'x-goog-api-key': key });
    const text = data.candidates?.[0]?.content?.parts?.map(part => part.text || '').join('');
    if (!text) throw new Error('Gemini zwróciło pustą odpowiedź');
    return { text, provider: 'gemini', model, fallback: true };
  } catch { throw new Error('Ollama i Gemini są niedostępne; sprawdź logi serwera i konfigurację'); }
}
