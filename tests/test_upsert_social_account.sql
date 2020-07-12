BEGIN;
	CREATE SCHEMA IF NOT EXISTS upsert_social_account_test;

	CREATE OR REPLACE FUNCTION upsert_social_account_test.test_function()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_function(
			'public',
			'upsert_social_account',
			ARRAY['provider', 'text', 'text', 'text', 'text', 'jsonb', 'text'],
			'should have function upsert_social_account'
		);
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION upsert_social_account_test.test_create()
	RETURNS SETOF TEXT AS $$
	BEGIN
		-- Run perform if there's no need to store the temp result (a.k.a discard the result).
		PERFORM upsert_social_account(
			'facebook',
			'fb-123',
			'john.doe@mail.com',
			'John Doe',
			'john-doe',
			'{}'::jsonb,
			'fb-secret-xyz'
		);

		RETURN NEXT isnt_empty('SELECT * FROM "user"', 'should not be empty');
		RETURN NEXT results_eq('SELECT count(*)::int FROM "user"', ARRAY[1], 'should create 1 user');
		RETURN NEXT results_eq('SELECT count(*)::int FROM account', ARRAY[1], 'should create 1 account');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION upsert_social_account_test.test_link_account_with_same_email()
	RETURNS SETOF TEXT AS $$
	BEGIN
		PERFORM upsert_email_account(
			'john.doe@mail.com',
			'12345678',
			'John Doe',
			'john-doe'
		);
		PERFORM upsert_social_account(
			'facebook',
			'fb-123',
			'john.doe@mail.com',
			'John Doe',
			'john-doe',
			'{}'::jsonb,
			'fb-secret-xyz'
		);

		RETURN NEXT isnt_empty('SELECT * FROM "user"', 'should not be empty');
		RETURN NEXT results_eq('SELECT count(*)::int FROM "user"', ARRAY[1], 'should create 1 user');
		RETURN NEXT results_eq('SELECT count(*)::int FROM account', ARRAY[2], 'should create 2 account');
		RETURN NEXT results_eq('SELECT count(distinct user_id)::int FROM account GROUP BY user_id', ARRAY[1], 'should have both accounts linked to the same user');
	END;
	$$ LANGUAGE plpgsql;

	-- There are many scenarios where the social media account does not have email, such as
	-- - when the user registered using mobile
	-- - when the email address is not verified on provider side
	-- - when user choose not to share the email address
	--
	-- When such scenario occurs, we cannot link the accounts correctly, and can only assume them
	-- to be standalone user accounts.
	CREATE OR REPLACE FUNCTION upsert_social_account_test.test_upsert_without_email()
	RETURNS SETOF TEXT AS $$
	BEGIN
		PERFORM upsert_social_account(
			'facebook',
			'fb-123',
			'',
			'John Doe',
			'john-doe',
			'{}'::jsonb,
			'fb-secret-xyz'
		);

		PERFORM upsert_social_account(
			'facebook',
			'fb-456',
			'',
			'John Doe',
			'john-doe',
			'{}'::jsonb,
			'fb-secret-xyz'
		);

		PERFORM upsert_social_account(
			'facebook',
			'fb-789',
			'',
			'John Doe',
			'john-doe',
			'{}'::jsonb,
			'fb-secret-xyz'
		);

		RETURN NEXT results_eq('SELECT count(*)::int FROM "user"', ARRAY[3], 'should create 3 distinct users');
		RETURN NEXT results_eq('SELECT count(*)::int FROM account', ARRAY[3], 'should create 3 accounts');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('upsert_social_account_test'::name);

ROLLBACK;
