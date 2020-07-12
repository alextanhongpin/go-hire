BEGIN;
	CREATE SCHEMA IF NOT EXISTS authenticate_test;

	CREATE OR REPLACE FUNCTION authenticate_test.test_table()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_function('public', 'authenticate', ARRAY['text', 'text'], 'should have function');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION authenticate_test.test_empty()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT throws_ok('SELECT * FROM authenticate(''john.doe@mail.com'', ''123456789'')', 'Email (john.doe@mail.com) or password is invalid', 'should return error if the email does not exist');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION authenticate_test.test_authenticate()
	RETURNS SETOF TEXT AS $$
	BEGIN
		PERFORM upsert_email_account('john.doe@mail.com', '12345678', 'John Doe', 'john-doe');
		RETURN NEXT isnt_empty('SELECT * FROM "user"', 'should create user');
		RETURN NEXT isnt_empty('SELECT * FROM authenticate(''john.doe@mail.com'', ''12345678'')', 'should return the user');
		RETURN NEXT throws_ok('SELECT * FROM authenticate(''john.doe@mail.com'', ''123456789'')', 'Email (john.doe@mail.com) or password is invalid', 'should return error if the email does not exist');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('authenticate_test'::name);

ROLLBACK;
