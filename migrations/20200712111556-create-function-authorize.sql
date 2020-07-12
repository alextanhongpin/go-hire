
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION authorize(provider provider, uid text)
RETURNS "user" AS $$
DECLARE
	out record;
BEGIN
	SELECT *
	INTO STRICT out
	FROM "user"
	WHERE id = (
		SELECT user_id
		FROM account
		WHERE account.provider = authorize.provider
		AND account.uid = authorize.uid
	);
	RETURN out;
EXCEPTION
	WHEN no_data_found THEN
		RAISE EXCEPTION 'Account (%=%) not found', provider, uid
			USING hint = 'Check if the given provider exists';
	WHEN too_many_rows THEN
		RAISE EXCEPTION 'Account (%=%) is not unique', provider, uid
			USING hint = 'Check if the given provider has duplicate records';
END;
$$ LANGUAGE plpgsql STABLE;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS authorize;
