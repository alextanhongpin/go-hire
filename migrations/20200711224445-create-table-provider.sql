
-- +migrate Up
CREATE TYPE provider AS enum ('email', 'phone', 'facebook', 'google');

-- +migrate Down
DROP TYPE IF EXISTS provider;
