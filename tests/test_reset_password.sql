BEGIN;
	CREATE SCHEMA IF NOT EXISTS reset_password_test;

	CREATE OR REPLACE FUNCTION reset_password_test.test_table()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_function('public', 'reset_password', ARRAY['text', 'text', 'int'], 'should have function');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION reset_password_test.test_empty()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT throws_ok('SELECT * FROM reset_password(''token-123'', ''new-password'', 1)', 'Reset password token token-123 not found', 'should return error if the reset password token is not found');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION reset_password_test.test_reset_password()
	RETURNS SETOF TEXT AS $$
	DECLARE
		local_reset_password_token text;
		out record;
	BEGIN
		PERFORM upsert_email_account('john.doe@mail.com', '12345678', 'John Doe', 'john-doe');
		SELECT reset_password_token
		INTO STRICT local_reset_password_token
		FROM request_reset_password('john.doe@mail.com');

		SELECT *
		INTO STRICT out
		FROM reset_password(local_reset_password_token, 'new-password');

		RETURN NEXT is(out.reset_password_token, NULL, 'should reset the reset_password_token column');
		RETURN NEXT is(out.reset_password_sent_at, NULL, 'should reset the reset_password_sent_at column');
		RETURN NEXT isnt_empty('SELECT authenticate(''john.doe@mail.com'', ''new-password'')', 'should authenticate with the new password');
	END;
	$$ LANGUAGE plpgsql;

	CREATE OR REPLACE FUNCTION reset_password_test.test_token_expired()
	RETURNS SETOF TEXT AS $$
	DECLARE
		local_reset_password_token text;
		out record;
	BEGIN
		PERFORM upsert_email_account('john.doe@mail.com', '12345678', 'John Doe', 'john-doe');
		SELECT reset_password_token
		INTO STRICT local_reset_password_token
		FROM request_reset_password('john.doe@mail.com');

		RETURN NEXT throws_ok(format('SELECT reset_password(%L, ''new-password'', -1)', local_reset_password_token), 'Reset password token expired', 'should return error if token expired');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('reset_password_test'::name);

ROLLBACK;
