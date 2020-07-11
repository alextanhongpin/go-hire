
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION upsert_email_account(email text, plaintext_password text, name text, slug text)
RETURNS account AS $email_account$
	WITH inserted_user AS (
		INSERT INTO "user" (email, name, preferred_username)
			VALUES (
				NULLIF(email, ''),
				NULLIF(name, ''),
				unique_slug(slug)
			)
		ON CONFLICT (email)
		DO UPDATE
		SET deleted_at = NULL
		RETURNING *
	)
	INSERT INTO account (user_id, uid, email, token, provider)
	VALUES (
		(SELECT id FROM inserted_user),
		email,
		email,
		encrypt_password(plaintext_password),
		'email'
	)
	RETURNING *;
$email_account$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION upsert_email_account IS 'Finds the user with given email, and create an email account with the given password';
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS upsert_email_account;
