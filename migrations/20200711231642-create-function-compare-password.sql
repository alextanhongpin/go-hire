
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION compare_password(plaintext_password text, encrypted_password text)
RETURNS boolean AS $match$
	SELECT encrypted_password = crypt(plaintext_password, encrypted_password);
$match$ LANGUAGE SQL STABLE;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS compare_password;
