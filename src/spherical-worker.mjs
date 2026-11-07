/**
 * Spherical worker observation: a 360-degree logical view of independent
 * system dimensions. This does NOT grant access to sensors or permissions.
 * Probes must be explicitly supplied and may run concurrently.
 */
export const DIMENSIONS = Object.freeze(['code','logs','processes','models','agents','security','resources']);
export async function observeSpherical(probes = {}, { timeoutMs = 5000 } = {}) {
  const startedAt = new Date().toISOString();
  const dimensions = await Promise.all(DIMENSIONS.map(async name => {
    const probe = probes[name];
    if (typeof probe !== 'function') return { name, status: 'unavailable', data: null };
    let timeout;
    try {
      const data = await Promise.race([
        Promise.resolve().then(() => probe()),
        new Promise((_, reject) => { timeout = setTimeout(() => reject(new Error('timeout')), timeoutMs); }),
      ]);
      return { name, status: 'ok', data };
    } catch (error) {
      return { name, status: 'error', error: error instanceof Error ? error.message : String(error) };
    } finally { clearTimeout(timeout); }
  }));
  return { startedAt, finishedAt: new Date().toISOString(), dimensions };
}
