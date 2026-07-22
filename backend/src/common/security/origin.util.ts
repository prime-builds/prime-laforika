import { createHmac, timingSafeEqual } from 'crypto';

/** HMAC fingerprint of a request origin — never store raw IPs. */
export function fingerprintOrigin(origin: string, pepper: string): string {
  return createHmac('sha256', pepper)
    .update(`origin:v1:${origin}`)
    .digest('hex');
}

/**
 * HMAC fingerprint of a challenge destination — never store raw email/phone.
 * Domain-separated from origin fingerprints.
 */
export function fingerprintDestination(input: {
  destinationType: string;
  destinationNormalized: string;
  purpose: string;
  pepper: string;
}): string {
  const material = [
    'destination:v1',
    input.destinationType,
    input.destinationNormalized,
    input.purpose,
  ].join(':');
  return createHmac('sha256', input.pepper).update(material).digest('hex');
}

/** Safe persisted rate-limit key — fingerprint only, no personal identifiers. */
export function destinationRateLimitBucketKey(input: {
  destinationType: string;
  destinationNormalized: string;
  purpose: string;
  pepper: string;
}): string {
  const fp = fingerprintDestination(input);
  return `challenge:dest:v1:${input.destinationType}:${fp}:${input.purpose}`;
}

export function constantTimeEqualString(a: string, b: string): boolean {
  const ba = Buffer.from(a);
  const bb = Buffer.from(b);
  if (ba.length !== bb.length) return false;
  return timingSafeEqual(ba, bb);
}

/**
 * Resolve a request-origin string for rate limiting.
 * Forwarded headers are trusted only when `trustForwarded` is true.
 */
export function resolveRequestOrigin(
  req: {
    ip?: string;
    socket?: { remoteAddress?: string };
    headers: Record<string, string | string[] | undefined>;
  },
  trustForwarded: boolean,
): string {
  if (trustForwarded) {
    const forwarded = req.headers['x-forwarded-for'];
    const first =
      typeof forwarded === 'string'
        ? forwarded.split(',')[0]?.trim()
        : Array.isArray(forwarded)
          ? forwarded[0]?.trim()
          : undefined;
    if (first) return first;
  }
  return req.ip || req.socket?.remoteAddress || 'unknown';
}

/** Parse a PostgreSQL URL and return the database name path segment. */
export function parseDatabaseName(databaseUrl: string): string {
  let parsed: URL;
  try {
    parsed = new URL(databaseUrl);
  } catch {
    throw new Error('DATABASE_URL is not a valid URL');
  }
  const name = parsed.pathname.replace(/^\//, '').split('/')[0];
  if (!name) {
    throw new Error('DATABASE_URL is missing a database name');
  }
  return decodeURIComponent(name);
}

/**
 * Fail-closed guard for destructive e2e database operations.
 * Throws before any connection/cleanup when misconfigured.
 */
export function assertDedicatedTestDatabase(env: {
  APP_ENVIRONMENT?: string;
  DATABASE_URL?: string;
  TEST_DATABASE_NAME?: string;
}): { databaseName: string } {
  if (env.APP_ENVIRONMENT !== 'test') {
    throw new Error('E2E requires APP_ENVIRONMENT=test');
  }
  const expected = env.TEST_DATABASE_NAME;
  if (!expected || !expected.endsWith('_test')) {
    throw new Error(
      'E2E requires TEST_DATABASE_NAME ending with _test (no defaults)',
    );
  }
  if (!env.DATABASE_URL) {
    throw new Error('E2E requires DATABASE_URL');
  }
  const actual = parseDatabaseName(env.DATABASE_URL);
  if (actual !== expected) {
    throw new Error(
      `E2E DATABASE_URL database "${actual}" does not match TEST_DATABASE_NAME "${expected}"`,
    );
  }
  return { databaseName: actual };
}
