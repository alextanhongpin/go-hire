
-- +migrate Up
CREATE TABLE IF NOT EXISTS slug (
	id serial PRIMARY KEY,
	name citext NOT NULL UNIQUE CHECK (LENGTH(name) > 0),
	counter int NOT NULL DEFAULT 0
);

-- +migrate Down
DROP TABLE IF EXISTS slug;
