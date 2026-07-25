import { readFileSync } from 'fs';
import { resolve } from 'path';

type OpenApiOperation = {
  security?: unknown[];
  responses?: Record<
    string,
    {
      content?: {
        'application/json'?: {
          schema?: unknown;
        };
      };
    }
  >;
};

function schemaMentionsErrorResponseDto(schema: unknown): boolean {
  if (!schema || typeof schema !== 'object') return false;
  const text = JSON.stringify(schema);
  return text.includes('#/components/schemas/ErrorResponseDto');
}

describe('OpenAPI contract', () => {
  const doc = JSON.parse(
    readFileSync(resolve(__dirname, '../../../openapi/openapi.json'), 'utf8'),
  ) as {
    paths: Record<string, Record<string, OpenApiOperation>>;
    components?: {
      schemas?: Record<string, { properties?: Record<string, unknown> }>;
    };
  };

  const pathOf = (path: string) => doc.paths[path] ?? doc.paths[`/v1${path}`];

  const ERROR_STATUS_MATRIX: Array<{
    path: string;
    method: string;
    statuses: number[];
  }> = [
    {
      path: '/auth/phone/challenges',
      method: 'post',
      statuses: [400, 429, 503],
    },
    {
      path: '/auth/phone/challenges/{challengeId}/verify',
      method: 'post',
      statuses: [400, 401],
    },
    { path: '/auth/refresh', method: 'post', statuses: [400, 401] },
    { path: '/account/me', method: 'get', statuses: [401] },
    { path: '/auth/sessions', method: 'get', statuses: [401] },
    {
      path: '/auth/sessions/{sessionId}',
      method: 'delete',
      statuses: [401, 404],
    },
    { path: '/auth/logout', method: 'post', statuses: [401] },
    { path: '/auth/logout-all', method: 'post', statuses: [401] },
  ];

  const REMOVED_PATHS = [
    '/auth/email/sign-up',
    '/auth/email/verify',
    '/auth/email/sign-in',
    '/auth/password/reset-challenges',
    '/auth/password/reset',
    '/account/phone/challenges',
    '/account/phone',
    '/account/email/challenges',
    '/account/email/verify',
    '/account/email',
    '/account/password',
  ];

  it('critical request schemas have non-empty properties', () => {
    const schemas = doc.components?.schemas ?? {};
    for (const name of ['PhoneDto', 'RefreshDto', 'CodeDto']) {
      const schema = schemas[name];
      expect(schema).toBeDefined();
      expect(Object.keys(schema?.properties ?? {}).length).toBeGreaterThan(0);
    }
    expect(schemas.EmailSignUpDto).toBeUndefined();
    expect(schemas.ChangePasswordDto).toBeUndefined();
  });

  it('critical response schemas have non-empty properties', () => {
    const schemas = doc.components?.schemas ?? {};
    for (const name of [
      'ChallengeResponseDto',
      'TokenResponseDto',
      'AccountViewDto',
      'ErrorResponseDto',
    ]) {
      const schema = schemas[name];
      if (!schema) {
        const keys = Object.keys(schemas).join(',');
        throw new Error(`Missing schema ${name}. Available: ${keys}`);
      }
      expect(Object.keys(schema.properties ?? {}).length).toBeGreaterThan(0);
    }
    expect(schemas.AccountViewDto?.properties?.hasPhone).toBeUndefined();
    expect(schemas.AccountViewDto?.properties?.hasEmail).toBeUndefined();
  });

  it('excludes fixture inbox from public paths', () => {
    expect(doc.paths['/dev/fixtures/inbox']).toBeUndefined();
    expect(doc.paths['/v1/dev/fixtures/inbox']).toBeUndefined();
  });

  it('removes deprecated email/password credential paths', () => {
    for (const path of REMOVED_PATHS) {
      expect(pathOf(path)).toBeUndefined();
    }
  });

  it('protects account/me with bearer security', () => {
    const me = pathOf('/account/me')?.get;
    expect(me).toBeDefined();
    expect(me?.security?.length ?? 0).toBeGreaterThan(0);
  });

  it('documents exact error status matrix with ErrorResponseDto', () => {
    for (const entry of ERROR_STATUS_MATRIX) {
      const op = pathOf(entry.path)?.[entry.method];
      expect(op).toBeDefined();
      const responses = op?.responses ?? {};
      for (const status of entry.statuses) {
        const response = responses[String(status)];
        expect(response).toBeDefined();
        const schema = response?.content?.['application/json']?.schema;
        expect(schemaMentionsErrorResponseDto(schema)).toBe(true);
      }
    }
  });

  it('success response schemas remain non-empty for critical operations', () => {
    const criticalSuccess: Array<{ path: string; method: string }> = [
      { path: '/auth/phone/challenges', method: 'post' },
      { path: '/auth/phone/challenges/{challengeId}/verify', method: 'post' },
      { path: '/auth/refresh', method: 'post' },
      { path: '/account/me', method: 'get' },
    ];
    for (const entry of criticalSuccess) {
      const op = pathOf(entry.path)?.[entry.method];
      const schema =
        op?.responses?.['200']?.content?.['application/json']?.schema;
      expect(schema).toBeDefined();
      expect(JSON.stringify(schema).length).toBeGreaterThan(0);
    }
  });
});
