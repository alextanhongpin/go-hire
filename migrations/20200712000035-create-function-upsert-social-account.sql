
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION upsert_social_account(
	provider provider,
	uid text,
	email text,
	name text,
	slug text,
	data jsonb,
	token text
) RETURNS account AS $$
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
	INSERT INTO account (user_id, uid, email, token, provider, data)
		VALUES ((select id from inserted_user), uid, email, token, provider, data)
	ON CONFLICT (provider, uid, user_id)
	DO UPDATE
	SET data = EXCLUDED.data,
		token = EXCLUDED.token
	RETURNING *;
$$ LANGUAGE SQL VOLATILE;
COMMENT ON FUNCTION upsert_social_account IS 'Find the user with the given email and create a social media account';
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS upsert_social_account;
