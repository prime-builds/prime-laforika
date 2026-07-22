-- AlterTable
ALTER TABLE "users" ADD COLUMN "email_verified_at" TIMESTAMP(3);

-- Intentionally no backfill: pre-remediation rows could have email/password
-- without completed verification. Leave email_verified_at NULL until the
-- real verification flow sets it.

-- AlterTable
ALTER TABLE "auth_challenges" ADD COLUMN "pending_password_hash" TEXT;
ALTER TABLE "auth_challenges" ADD COLUMN "pending_email_display" TEXT;

-- DropTable: plaintext fixture codes must not persist in PostgreSQL.
DROP TABLE IF EXISTS "fixture_inbox_messages";
