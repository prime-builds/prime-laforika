import { readFileSync } from 'fs';
import { resolve } from 'path';

describe('email_verified_at migration SQL', () => {
  const sql = readFileSync(
    resolve(
      __dirname,
      '../../../prisma/migrations/20260722183000_verified_email_and_drop_fixture_inbox/migration.sql',
    ),
    'utf8',
  );

  it('does not backfill email_verified_at from created_at', () => {
    expect(sql).not.toMatch(
      /UPDATE\s+"users"[\s\S]*?"email_verified_at"\s*=\s*"created_at"/i,
    );
    expect(sql).not.toMatch(/"email_verified_at"\s*=\s*"created_at"/i);
    expect(sql.toLowerCase()).not.toMatch(
      /set\s+"?email_verified_at"?\s*=\s*"?created_at"?/,
    );
  });
});
