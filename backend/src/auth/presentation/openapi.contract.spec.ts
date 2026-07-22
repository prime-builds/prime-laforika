import { readFileSync } from 'fs';
import { resolve } from 'path';

describe('OpenAPI contract', () => {
  const doc = JSON.parse(
    readFileSync(resolve(__dirname, '../../../openapi/openapi.json'), 'utf8'),
  ) as {
    paths: Record<string, Record<string, unknown>>;
    components?: {
      schemas?: Record<string, { properties?: Record<string, unknown> }>;
    };
  };

  it('critical request schemas have non-empty properties', () => {
    const schemas = doc.components?.schemas ?? {};
    for (const name of [
      'PhoneDto',
      'EmailSignUpDto',
      'EmailSignInDto',
      'RefreshDto',
      'ChangePasswordDto',
    ]) {
      const schema = schemas[name];
      expect(schema).toBeDefined();
      expect(Object.keys(schema?.properties ?? {}).length).toBeGreaterThan(0);
    }
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
  });

  it('excludes fixture inbox from public paths', () => {
    expect(doc.paths['/dev/fixtures/inbox']).toBeUndefined();
    expect(doc.paths['/v1/dev/fixtures/inbox']).toBeUndefined();
  });

  it('protects account/me with bearer security', () => {
    const me = (doc.paths['/account/me']?.get ??
      doc.paths['/v1/account/me']?.get) as { security?: unknown[] } | undefined;
    expect(me).toBeDefined();
    expect(me?.security?.length ?? 0).toBeGreaterThan(0);
  });
});
