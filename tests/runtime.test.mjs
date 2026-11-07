import test from 'node:test';
import assert from 'node:assert/strict';
import { generateReply } from '../src/llm.mjs';
test('fallback error when both providers unavailable', async () => {
  const oldFetch=globalThis.fetch, oldKey=process.env.GEMINI_API_KEY, oldUrl=process.env.OLLAMA_BASE_URL;
  globalThis.fetch=async()=>{throw new Error('offline')};
  delete process.env.GEMINI_API_KEY;
  process.env.OLLAMA_BASE_URL='http://127.0.0.1:11434';
  try {await assert.rejects(generateReply('test'), /fallback nie jest skonfigurowany/);}
  finally {globalThis.fetch=oldFetch; if(oldKey===undefined) delete process.env.GEMINI_API_KEY;else process.env.GEMINI_API_KEY=oldKey;if(oldUrl===undefined)delete process.env.OLLAMA_BASE_URL;else process.env.OLLAMA_BASE_URL=oldUrl;}
});
test('Ollama response reports actual provider',async()=>{
 const old=globalThis.fetch;
 globalThis.fetch=async()=>({ok:true,json:async()=>({message:{content:'Odpowiedź'}})});
 try {const r=await generateReply('test');assert.equal(r.provider,'ollama');assert.equal(r.fallback,false);assert.equal(r.text,'Odpowiedź');}finally{globalThis.fetch=old;}
});
test('Gemini fallback reports provider',async()=>{
 const old=globalThis.fetch, key=process.env.GEMINI_API_KEY;
 process.env.GEMINI_API_KEY='test-key';
 globalThis.fetch=async url=>url.includes('/api/chat')?{ok:false,status:503,json:async()=>({})}:{ok:true,json:async()=>({candidates:[{content:{parts:[{text:'Gemini OK'}]}}]})};
 try {const r=await generateReply('test');assert.equal(r.provider,'gemini');assert.equal(r.fallback,true);assert.equal(r.text,'Gemini OK');}finally{globalThis.fetch=old;if(key===undefined)delete process.env.GEMINI_API_KEY;else process.env.GEMINI_API_KEY=key;}
});
