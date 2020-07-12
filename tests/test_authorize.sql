BEGIN;
	CREATE SCHEMA IF NOT EXISTS authorize_test;

	CREATE OR REPLACE FUNCTION authorize_test.test_table()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_function('public', 'authorize', ARRAY['provider', 'text'], 'should have function authorize');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION authorize_test.test_empty()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT throws_ok('SELECT * FROM authorize(''email'', ''123456789'')', 'Account (email=123456789) not found', 'should return error if the provider does not exist');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION authorize_test.test_authorize()
	RETURNS SETOF TEXT AS $$
	BEGIN
		PERFORM upsert_social_account(
			'facebook',
			'fb-123',
			'john.doe@mail.com',
			'John Doe',
			'john-doe',
			'{}'::jsonb,
			'fb-secret-xyz'
		);
		RETURN NEXT isnt_empty('SELECT * FROM "user"', 'should create user');
		RETURN NEXT isnt_empty('SELECT * FROM account', 'should create account');
		RETURN NEXT results_eq('SELECT * FROM authorize(''facebook'', ''fb-123'')', 'SELECT * FROM "user" WHERE email = ''john.doe@mail.com''', 'should return the authorized user');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('authorize_test'::name);

ROLLBACK;
