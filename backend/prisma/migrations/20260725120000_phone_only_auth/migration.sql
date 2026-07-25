-- M03_WP03: phone-only authentication schema.
-- Fail closed if any account lacks a phone identity before dropping password credentials.

DO $$
DECLARE
  orphan_count integer;
BEGIN
  SELECT COUNT(*) INTO orphan_count FROM users WHERE phone_e164 IS NULL;
  IF orphan_count > 0 THEN
    RAISE EXCEPTION
      'M03_WP03 phone-only migration blocked: % account(s) lack phone identity',
      orphan_count;
  END IF;
END $$;

-- Remove deprecated credential challenges before narrowing enums.
DELETE FROM auth_challenges
WHERE purpose <> 'PHONE_SIGN_IN'
   OR destination_type <> 'PHONE';

ALTER TABLE auth_challenges
  DROP COLUMN IF EXISTS pending_password_hash,
  DROP COLUMN IF EXISTS pending_email_display;

ALTER TABLE users
  DROP COLUMN IF EXISTS password_hash;

ALTER TABLE users
  ALTER COLUMN phone_e164 SET NOT NULL;

-- Narrow ChallengePurpose to PHONE_SIGN_IN only.
CREATE TYPE "ChallengePurpose_new" AS ENUM ('PHONE_SIGN_IN');
ALTER TABLE auth_challenges
  ALTER COLUMN purpose TYPE "ChallengePurpose_new"
  USING (purpose::text::"ChallengePurpose_new");
DROP TYPE "ChallengePurpose";
ALTER TYPE "ChallengePurpose_new" RENAME TO "ChallengePurpose";

-- Narrow DestinationType to PHONE only.
CREATE TYPE "DestinationType_new" AS ENUM ('PHONE');
ALTER TABLE auth_challenges
  ALTER COLUMN destination_type TYPE "DestinationType_new"
  USING (destination_type::text::"DestinationType_new");
DROP TYPE "DestinationType";
ALTER TYPE "DestinationType_new" RENAME TO "DestinationType";
