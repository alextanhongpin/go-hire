
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
	NEW.updated_at = now();
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- +migrate StatementEnd

-- USAGE:
-- CREATE TRIGGER update_timestamp
-- BEFORE INSERT OR UPDATE on tablename
-- FOR EACH ROW
-- EXECUTE PROCEDURE update_timestamp();

-- +migrate Down
DROP FUNCTION IF EXISTS update_timestamp;
