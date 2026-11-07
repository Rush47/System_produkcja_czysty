import express from 'express';
import dotenv from 'dotenv';
import { fileURLToPath } from 'node:url';
import path from 'node:path';
import { generateReply } from './src/llm.mjs';

dotenv.config();
const app = express();
app.disable('x-powered-by');
app.use(express.json({ limit: '1mb' }));
const root = path.dirname(fileURLToPath(import.meta.url));
app.use(express.static(path.join(root, 'public')));
app.get('/api/health', (_req, res) => res.json({ status: 'ok', mode: 'real', timestamp: new Date().toISOString() }));
app.get('/api/models', (_req, res) => res.json({ primary: { provider: 'ollama', model: process.env.OLLAMA_MODEL || 'llama3.1:8b' }, fallback: { provider: 'gemini', model: process.env.GEMINI_MODEL || 'gemini-2.5-flash-lite', configured: Boolean(process.env.GEMINI_API_KEY) } }));
app.post('/api/chat', async (req, res) => {
  const message = req.body?.message;
  if (typeof message !== 'string' || !message.trim() || message.length > 16000) return res.status(400).json({ error: 'Wymagana wiadomość (1–16000 znaków)' });
  try { res.json(await generateReply(message)); }
  catch (error) { res.status(503).json({ error: error instanceof Error ? error.message : 'Brak dostępnego modelu' }); }
});
app.use('/api', (_req, res) => res.status(404).json({ error: 'Endpoint nie istnieje' }));
const port = Number(process.env.PORT || 3000);
if (process.env.NODE_ENV !== 'test') app.listen(port, '0.0.0.0', () => console.log('System listening on port ' + port));
export default app;
