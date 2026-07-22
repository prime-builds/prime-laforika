import { config } from 'dotenv';
import { resolve } from 'path';

config({ path: resolve(__dirname, '../.env.test'), quiet: true });
config({ path: resolve(__dirname, '../.env'), quiet: true });

process.env.APP_ENVIRONMENT = process.env.APP_ENVIRONMENT ?? 'test';
if (!process.env.DATABASE_URL?.includes('laforika_test')) {
  process.env.DATABASE_URL =
    process.env.DATABASE_URL?.replace('laforika_dev', 'laforika_test') ??
    'postgresql://postgres:postgres@127.0.0.1:5432/laforika_test';
}
process.env.FIXTURE_DELIVERY_ENABLED = 'true';
