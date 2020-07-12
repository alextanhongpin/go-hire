
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION unlink_account(user_id uuid, provider provider, uid text)
RETURNS account AS $$
DECLARE
	accounts_count int;
	account_exists boolean;
	out record;
BEGIN
	SELECT count(*)
	INTO STRICT accounts_count
	FROM account
	WHERE account.user_id = $1
	GROUP BY account.user_id;

	SELECT true
	INTO STRICT account_exists
	FROM account
	WHERE account.user_id = $1
	AND account.provider = $2
	AND account.uid = $3;

	IF account_exists AND accounts_count = 1 THEN
		RAISE EXCEPTION 'Primary account cannot be deleted'
		USING hint = 'Check that you are not deleting the only account for the user';
	END IF;

	DELETE FROM account
	WHERE account.user_id = $1
	AND account.provider = $2
	AND account.uid = $3
	RETURNING * INTO STRICT out;

	RETURN out;
END;
$$ LANGUAGE plpgsql;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS unlink_account;
