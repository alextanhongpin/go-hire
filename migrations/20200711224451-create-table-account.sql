
-- +migrate Up
CREATE TABLE IF NOT EXISTS account (
	id UUID PRIMARY KEY default gen_random_uuid(),
	uid TEXT UNIQUE NOT NULL,
	provider PROVIDER NOT NULL,
	token TEXT NOT NULL,
	user_id UUID NOT NULL,

	email TEXT NOT NULL DEFAULT '',
	data JSONB NOT NULL DEFAULT '{}'::jsonb,

	-- Timestamps.
	created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
	updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT current_timestamp,
	deleted_at TIMESTAMP WITH TIME ZONE NULL,

	-- Each user can only have a unique provider (though they can have multiple accounts of the same provider).
	UNIQUE (uid, provider, user_id),
	FOREIGN KEY(user_id) REFERENCES "user"(id)
);

CREATE TRIGGER update_timestamp
BEFORE UPDATE ON account
FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

COMMENT ON COLUMN account.uid IS 'The id of the provider, e.g for email provider, the id is the email, for other provider the id is the unique id of the provider';
COMMENT ON COLUMN account.provider IS 'One of email, facebook, google etc';
COMMENT ON COLUMN account.token IS 'The encrypted password if the provider is Email, otherwise the access token of the provider';
COMMENT ON COLUMN account.user_id IS 'The owner of the account - one user can have many accounts with the same provider, but with unique provider id';
COMMENT ON COLUMN account.email IS 'The email of the provider - allows linking of account by similar email to be done';


-- +migrate Down
DROP TABLE IF EXISTS account;
