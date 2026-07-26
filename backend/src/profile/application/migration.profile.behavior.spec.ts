import { config } from 'dotenv';
import { execFileSync } from 'child_process';
import { randomUUID } from 'crypto';
import { readFileSync } from 'fs';
import { resolve } from 'path';
import { PrismaClient } from '@prisma/client';
import {
  assertDedicatedTestDatabase,
  parseDatabaseName,
} from '../../common/security/origin.util';

config({ path: resolve(__dirname, '../../../.env'), quiet: true });
config({
  path: resolve(__dirname, '../../../.env.test'),
  override: true,
  quiet: true,
});
process.env.APP_ENVIRONMENT = 'test';

const backendRoot = resolve(__dirname, '../../..');
const migrationsDir = resolve(backendRoot, 'prisma/migrations');

const MIGRATIONS = [
  '20260722093227_init_auth',
  '20260722183000_verified_email_and_drop_fixture_inbox',
  '20260725120000_phone_only_auth',
  '20260726120000_profile_names',
] as const;

function requireTestDatabaseUrl(): string {
  assertDedicatedTestDatabase({
    APP_ENVIRONMENT: process.env.APP_ENVIRONMENT,
    DATABASE_URL: process.env.DATABASE_URL,
    TEST_DATABASE_NAME: process.env.TEST_DATABASE_NAME,
  });
  return process.env.DATABASE_URL as string;
}

function withDatabaseName(url: string, databaseName: string): string {
  const parsed = new URL(url);
  parsed.pathname = `/${databaseName}`;
  return parsed.toString();
}

function adminUrl(url: string): string {
  return withDatabaseName(url, 'postgres');
}

function prismaClient(url: string): PrismaClient {
  return new PrismaClient({
    datasources: { db: { url } },
  });
}

function runSql(url: string, sql: string): void {
  const prismaCli = require.resolve('prisma/build/index.js');
  try {
    execFileSync(
      process.execPath,
      [
        prismaCli,
        'db',
        'execute',
        '--stdin',
        '--schema',
        'prisma/schema.prisma',
      ],
      {
        cwd: backendRoot,
        env: { ...process.env, DATABASE_URL: url },
        input: sql,
        encoding: 'utf8',
        stdio: ['pipe', 'pipe', 'pipe'],
      },
    );
  } catch (error) {
    const err = error as {
      stdout?: string;
      stderr?: string;
      message?: string;
    };
    const detail = [err.stderr, err.stdout, err.message]
      .filter(Boolean)
      .join('\n');
    throw new Error(detail || 'prisma db execute failed');
  }
}

function migrationSql(name: string): string {
  return readFileSync(resolve(migrationsDir, name, 'migration.sql'), 'utf8');
}

async function recreateDatabase(
  url: string,
  databaseName: string,
): Promise<void> {
  const admin = prismaClient(adminUrl(url));
  try {
    await admin.$executeRawUnsafe(
      `DROP DATABASE IF EXISTS "${databaseName}" WITH (FORCE)`,
    );
    await admin.$executeRawUnsafe(`CREATE DATABASE "${databaseName}"`);
  } finally {
    await admin.$disconnect();
  }
}

async function columnMeta(
  client: PrismaClient,
  column: string,
): Promise<{
  data_type: string;
  is_nullable: string;
  character_maximum_length: number | null;
}> {
  const rows = await client.$queryRaw<
    Array<{
      data_type: string;
      is_nullable: string;
      character_maximum_length: number | null;
    }>
  >`
    SELECT data_type, is_nullable, character_maximum_length
    FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name = 'users'
      AND column_name = ${column}
  `;
  return rows[0];
}

describe('profile_names migration behavior', () => {
  jest.setTimeout(120_000);

  const sourceUrl = requireTestDatabaseUrl();
  const disposableName = `laforika_mig_wp05_${Date.now()}_test`;
  const disposableUrl = withDatabaseName(sourceUrl, disposableName);

  afterAll(async () => {
    const admin = prismaClient(adminUrl(sourceUrl));
    try {
      await admin.$executeRawUnsafe(
        `DROP DATABASE IF EXISTS "${disposableName}" WITH (FORCE)`,
      );
    } finally {
      await admin.$disconnect();
    }
  });

  it('migrates a clean database through full history including profile names', async () => {
    await recreateDatabase(sourceUrl, disposableName);
    for (const name of MIGRATIONS) {
      runSql(disposableUrl, migrationSql(name));
    }

    const client = prismaClient(disposableUrl);
    try {
      const first = await columnMeta(client, 'first_name');
      const last = await columnMeta(client, 'last_name');
      expect(first.is_nullable).toBe('YES');
      expect(last.is_nullable).toBe('YES');
      expect(first.character_maximum_length).toBe(100);
      expect(last.character_maximum_length).toBe(100);
    } finally {
      await client.$disconnect();
    }
  });

  it('keeps phone account, sessions, and email values with null names', async () => {
    await recreateDatabase(sourceUrl, disposableName);
    for (const name of MIGRATIONS.slice(0, 3)) {
      runSql(disposableUrl, migrationSql(name));
    }

    const before = prismaClient(disposableUrl);
    const accountId = randomUUID();
    const sessionId = randomUUID();
    const familyId = randomUUID();
    const phone = `+98912${String(Date.now()).slice(-7)}`;
    const emailLocal = `prof_${accountId.replace(/-/g, '').slice(0, 12)}`;
    try {
      await before.$executeRawUnsafe(`
        INSERT INTO users (
          id, phone_e164, email_normalized, email_display, email_verified_at,
          created_at, updated_at
        ) VALUES (
          '${accountId}'::uuid, '${phone}', '${emailLocal}@example.com',
          '${emailLocal}@Example.com', NOW(), NOW(), NOW()
        )
      `);
      await before.$executeRawUnsafe(`
        INSERT INTO auth_sessions (
          id, user_id, family_id, absolute_expires_at, last_seen_at, created_at
        ) VALUES (
          '${sessionId}'::uuid, '${accountId}'::uuid, '${familyId}'::uuid,
          NOW() + interval '30 days', NOW(), NOW()
        )
      `);
    } finally {
      await before.$disconnect();
    }

    runSql(disposableUrl, migrationSql(MIGRATIONS[3]));

    const after = prismaClient(disposableUrl);
    try {
      const users = await after.$queryRaw<
        Array<{
          id: string;
          phone_e164: string;
          first_name: string | null;
          last_name: string | null;
          email_normalized: string;
          email_display: string;
          email_verified_at: Date | null;
        }>
      >`
        SELECT id::text AS id, phone_e164, first_name, last_name,
               email_normalized, email_display, email_verified_at
        FROM users WHERE id = ${accountId}::uuid
      `;
      expect(users).toHaveLength(1);
      expect(users[0].id).toBe(accountId);
      expect(users[0].phone_e164).toBe(phone);
      expect(users[0].first_name).toBeNull();
      expect(users[0].last_name).toBeNull();
      expect(users[0].email_normalized).toBe(`${emailLocal}@example.com`);
      expect(users[0].email_display).toBe(`${emailLocal}@Example.com`);
      expect(users[0].email_verified_at).not.toBeNull();

      const sessions = await after.$queryRaw<Array<{ id: string }>>`
        SELECT id::text AS id FROM auth_sessions WHERE id = ${sessionId}::uuid
      `;
      expect(sessions).toHaveLength(1);
    } finally {
      await after.$disconnect();
    }
  });

  it('keeps historical migration SQL present', () => {
    expect(parseDatabaseName(sourceUrl)).toMatch(/_test$/);
    for (const name of MIGRATIONS) {
      expect(migrationSql(name).length).toBeGreaterThan(0);
    }
  });
});
