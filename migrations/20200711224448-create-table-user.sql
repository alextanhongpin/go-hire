
-- +migrate Up
CREATE TABLE IF NOT EXISTS "user" (
	id UUID PRIMARY KEY default gen_random_uuid(),

	-- Email.
	email TEXT NULL UNIQUE,
	email_verified BOOLEAN NOT NULL DEFAULT false,

	-- Phone.
	phone_number TEXT NOT NULL DEFAULT '',
	phone_number_verified BOOLEAN NOT NULL DEFAULT false,

	-- Profile.
	name TEXT NOT NULL DEFAULT '',
	family_name TEXT NOT NULL DEFAULT '',
	given_name TEXT NOT NULL DEFAULT '',
	middle_name TEXT NOT NULL DEFAULT '',
	nickname TEXT NOT NULL DEFAULT '',
	preferred_username TEXT UNIQUE NOT NULL DEFAULT '',
	profile TEXT NOT NULL DEFAULT '',
	picture TEXT NOT NULL DEFAULT '',
	website TEXT NOT NULL DEFAULT '',
	gender CHAR(1) NOT NULL DEFAULT '',
	birthdate DATE NULL,
	zoneinfo TEXT NOT NULL DEFAULT '',
	locale TEXT NOT NULL DEFAULT '',

	-- Address.
	street_address TEXT NOT NULL DEFAULT '',
	locality TEXT NOT NULL DEFAULT '',
	region TEXT NOT NULL DEFAULT '',
	postal_code TEXT NOT NULL DEFAULT '',
	country TEXT NOT NULL DEFAULT '',

	-- Confirmable.
	confirmation_token TEXT UNIQUE NULL,
	confirmation_sent_at TIMESTAMP WITH TIME ZONE NULL,
	confirmed_at TIMESTAMP WITH TIME ZONE NULL,
	unconfirmed_email TEXT NOT NULL DEFAULT '',

	-- Recoverable.
	reset_password_token TEXT UNIQUE NULL,
	reset_password_sent_at TIMESTAMP WITH TIME ZONE NULL,
	allow_password_change BOOLEAN NOT NULL DEFAULT false,

	-- Trackable.
	sign_in_count INT NOT NULL DEFAULT 0,
	current_sign_in_at TIMESTAMP WITH TIME ZONE NULL,
	current_sign_in_ip INET NOT NULL DEFAULT '0.0.0.0'::inet,
	current_sign_in_user_agent TEXT NOT NULL DEFAULT '',
	last_sign_in_at TIMESTAMP WITH TIME ZONE NULL,
	last_sign_in_ip INET NOT NULL DEFAULT '0.0.0.0'::inet,
	last_sign_in_user_agent TEXT NOT NULL DEFAULT '',
	last_sign_out_at TIMESTAMP WITH TIME ZONE NULL,
	last_sign_out_ip INET NOT NULL DEFAULT '0.0.0.0'::inet,
	last_sign_out_user_agent TEXT NOT NULL DEFAULT '',

	-- Timestamps.
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
	deleted_at TIMESTAMP WITH TIME ZONE NULL
);

CREATE TRIGGER update_timestamp
BEFORE UPDATE ON "user"
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

-- The only way to escape single quote is by doubling them...
COMMENT ON COLUMN "user".profile IS 'URL of the End-User''s profile page';
COMMENT ON COLUMN "user".website IS 'URL of the End-User''s Web page or blog';
COMMENT ON COLUMN "user".gender IS 'End-User''s gender (m|f|o|x)';
COMMENT ON COLUMN "user".birthdate IS 'End-User''s birthday, represented as an ISO 8601:2004 [ISO8601?2004] YYYY-MM-DD format. The year MAY be 0000, indicating that it is omitted';
COMMENT ON COLUMN "user".zoneinfo IS 'String from zoneinfo [zoneinfo] time zone database representing the End-User''s time zone. For example, Europe/Paris or America/Los_Angeles';
COMMENT ON COLUMN "user".locale IS 'End-User''s locale, represented as a BCP47 [RFC5646] language tag. This is typically an ISO 639-1 Alpha-2 [ISO639?1] language code in lowercase and an ISO 3166-1 Alpha-2 [ISO3166?1] country code in uppercase, separated by a dash. For example, en-US or fr-CA. As a compatibility note, some implementations have used an underscore as the separator rather than a dash, for example, en_US';
COMMENT ON COLUMN "user".street_address IS 'Full street address component, which MAY include house number, street name, Post Office Box, and multi-line extended street address information. This field MAY contain multiple lines, separated by newlines. Newlines can be represented either as a carriage return/line feed pair ("\r\n") or as a single line feed character ("\n").';
COMMENT ON COLUMN "user".locality IS 'City or locality component.';
COMMENT ON COLUMN "user".region IS 'State, province, prefecture or region component.';
COMMENT ON COLUMN "user".postal_code IS 'Zip code or postal code component.';
COMMENT ON COLUMN "user".country IS 'Country name component.';

-- +migrate Down
DROP TABLE IF EXISTS "user";
