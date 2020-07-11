
-- +migrate Up
-- +migrate StatementBegin
CREATE OR REPLACE FUNCTION unique_slug(name TEXT) RETURNS text AS $$
	INSERT INTO slug(name)
	VALUES (name)
	ON CONFLICT (name)
	DO UPDATE SET counter = slug.counter + 1
	RETURNING
	CASE
		WHEN slug.counter = 0
			THEN name
		ELSE format('%s-%s', name, slug.counter)
	END;
$$ LANGUAGE SQL VOLATILE;
-- +migrate StatementEnd

-- +migrate Down
DROP FUNCTION IF EXISTS unique_slug;
