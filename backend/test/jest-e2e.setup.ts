import { config } from 'dotenv';
import { resolve } from 'path';
import { assertDedicatedTestDatabase } from '../src/common/security/origin.util';

config({ path: resolve(__dirname, '../.env.test'), quiet: true });
config({ path: resolve(__dirname, '../.env'), quiet: true });

process.env.APP_ENVIRONMENT = process.env.APP_ENVIRONMENT ?? 'test';

assertDedicatedTestDatabase({
  APP_ENVIRONMENT: process.env.APP_ENVIRONMENT,
  DATABASE_URL: process.env.DATABASE_URL,
  TEST_DATABASE_NAME: process.env.TEST_DATABASE_NAME,
});

process.env.FIXTURE_DELIVERY_ENABLED = 'true';
process.env.DELIVERY_MODE = process.env.DELIVERY_MODE ?? 'fixture';
