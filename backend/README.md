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
# Edit .env: DATABASE_URL, peppers, FIXTURE_INBOX_KEY, key paths
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

- Fixture inbox (`/v1/dev/fixtures/...`) is registered only when `APP_ENVIRONMENT` is `dev` or `test` and `FIXTURE_DELIVERY_ENABLED=true`.
- Never commit `.env`, `secrets/`, PEM files, or database dumps.
