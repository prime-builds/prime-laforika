# Backend — Laforika authentication API

NestJS + PostgreSQL custom authentication service for Laforika (M1).

## Prerequisites (native Windows)

- Node.js 24 LTS + npm
- PostgreSQL 16+ (native Windows service; Docker/WSL not required)
- OpenSSL or Node crypto for RS256 key generation

## Setup (PowerShell)

```powershell
cd backend
Copy-Item .env.example .env
npm run keys:generate
# Edit .env: DATABASE_URL, peppers (including RATE_LIMIT_PEPPER),
# FIXTURE_INBOX_KEY, DELIVERY_MODE=fixture, TRUST_FORWARDED_ORIGIN=false, key paths
npm ci
npx prisma migrate deploy
npm run start:dev
```

Health: `GET http://127.0.0.1:3000/v1/health`

## Quality gates

```powershell
npm run format:check
npm run lint
npm run typecheck
npm run prisma:format:check
npm run prisma:validate
npm run test
npm run test:e2e
npm run openapi:export
```

## Notes

- Fixture inbox (`/v1/dev/fixtures/...`) is registered only when `APP_ENVIRONMENT` is `dev` or `test`, `FIXTURE_DELIVERY_ENABLED=true`, and `DELIVERY_MODE=fixture`. Codes are kept in a process-local inbox — never PostgreSQL.
- Staging/prod require `DELIVERY_MODE=unavailable` (fail closed until a real SMS/email adapter exists).
- E2E tests require `APP_ENVIRONMENT=test`, `TEST_DATABASE_NAME` ending in `_test`, and a matching `DATABASE_URL` database name (no silent rewrite).
- Never commit `.env`, `secrets/`, PEM files, or database dumps.
