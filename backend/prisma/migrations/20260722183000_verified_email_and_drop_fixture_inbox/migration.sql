-- AlterTable
ALTER TABLE "users" ADD COLUMN "email_verified_at" TIMESTAMP(3);

-- Backfill: existing rows with email+password are treated as verified.
UPDATE "users"
SET "email_verified_at" = "created_at"
WHERE "email_normalized" IS NOT NULL AND "password_hash" IS NOT NULL;

-- AlterTable
ALTER TABLE "auth_challenges" ADD COLUMN "pending_password_hash" TEXT;
ALTER TABLE "auth_challenges" ADD COLUMN "pending_email_display" TEXT;

-- DropTable: plaintext fixture codes must not persist in PostgreSQL.
DROP TABLE IF EXISTS "fixture_inbox_messages";
