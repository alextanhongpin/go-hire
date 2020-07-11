BEGIN;
	CREATE SCHEMA IF NOT EXISTS upsert_email_account_test;

	CREATE OR REPLACE FUNCTION upsert_email_account_test.test_function()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_function(
			'public',
			'upsert_email_account',
			ARRAY['text', 'text', 'text', 'text'],
			'should have function upsert_email_account'
		);
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION upsert_email_account_test.test_create()
	RETURNS SETOF TEXT AS $$
	DECLARE
		local_user "user";
		local_account account;
	BEGIN
		-- Run perform if there's no need to store the temp result (a.k.a discard the result).
		PERFORM upsert_email_account(
			'john.doe@mail.com',
			'12345678',
			'John Doe',
			'john-doe'
		);

		SELECT *
		INTO local_account
		FROM upsert_email_account(
			'jane.doe@mail.com',
			'12345678',
			'John Doe',
			'john-doe'
		);

		SELECT *
		INTO local_user
		FROM "user"
		WHERE id = (local_account.user_id);

		RETURN NEXT is(local_account IS NULL, false, 'should create account');
		RETURN NEXT is(local_user IS NULL, false, 'should create user');
		RETURN NEXT is(local_user.id, local_account.user_id, 'should have relation user-account');
		RETURN NEXT is(local_user.preferred_username, 'john-doe-1', 'should increment the slug when username is the same');
		RETURN NEXT isnt_empty('SELECT * FROM "user"', 'should not be empty');
		RETURN NEXT results_eq('SELECT count(*)::int FROM "user"', ARRAY[2], 'should create 2 users');
		RETURN NEXT results_eq('SELECT count(*)::int FROM account', ARRAY[2], 'should create 2 accounts');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('upsert_email_account_test'::name);

ROLLBACK;
