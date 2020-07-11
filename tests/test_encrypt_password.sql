BEGIN;
	CREATE SCHEMA IF NOT EXISTS encrypt_password_test;

	CREATE OR REPLACE FUNCTION encrypt_password_test.test_function()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_function('public', 'encrypt_password', ARRAY['text', 'integer', 'integer'], 'should have function encrypt_password');
		RETURN NEXT has_function('public', 'compare_password', ARRAY['text', 'text'], 'should have function compare_password');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION encrypt_password_test.test_encrypt()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT throws_ok('SELECT encrypt_password('''')', 'Password is required', 'should return error when password is empty');
		RETURN NEXT throws_ok('SELECT encrypt_password(12345::text)', 'Password must be at least 6 characters', 'should return error when password is too short');
		RETURN NEXT throws_ok('SELECT encrypt_password(12345::text, 7)', 'Password must be at least 7 characters', 'should return error when password is shorter than the specified length');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION encrypt_password_test.test_compare()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT ok(compare_password('123456', encrypt_password('123456')), 'should match password');
		RETURN NEXT ok(NOT compare_password('1234567', encrypt_password('123456')), 'should not match password');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('encrypt_password_test'::name);

ROLLBACK;
