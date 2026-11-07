import test from 'node:test';
import assert from 'node:assert/strict';
import { observeSpherical, DIMENSIONS } from '../src/spherical-worker.mjs';
test('spherical worker reports unavailable probes honestly', async () => {
 const result = await observeSpherical({logs: async () => ['real log']});
 assert.equal(result.dimensions.length, DIMENSIONS.length);
 assert.equal(result.dimensions.find(d=>d.name==='logs').status,'ok');
 assert.equal(result.dimensions.find(d=>d.name==='security').status,'unavailable');
});
test('probe failures are isolated', async () => {
 const result = await observeSpherical({code:()=>{throw Error('failed')},processes:()=>({count:2})});
 assert.equal(result.dimensions.find(d=>d.name==='code').status,'error');
 assert.equal(result.dimensions.find(d=>d.name==='processes').status,'ok');
});
