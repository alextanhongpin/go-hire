BEGIN;
	CREATE SCHEMA IF NOT EXISTS request_reset_password_test;

	CREATE OR REPLACE FUNCTION request_reset_password_test.test_table()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_function('public', 'request_reset_password', ARRAY['text'], 'should have function');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION request_reset_password_test.test_empty()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT throws_ok('SELECT * FROM request_reset_password(''john.doe@mail.com'')', 'Email john.doe@mail.com not found', 'should return error if the token does not exist');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION request_reset_password_test.test_request_reset_password()
	RETURNS SETOF TEXT AS $$
	DECLARE
		out record;
	BEGIN
		PERFORM upsert_email_account('john.doe@mail.com', '12345678', 'John Doe', 'john-doe');
		SELECT *
		INTO STRICT out
		FROM request_reset_password('john.doe@mail.com');

		RETURN NEXT ok(out.reset_password_token IS NOT NULL, 'should set the reset_password_token field');
		RETURN NEXT ok(out.reset_password_sent_at IS NOT NULL, 'should set the reset_password_sent_at field');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('request_reset_password_test'::name);

ROLLBACK;
