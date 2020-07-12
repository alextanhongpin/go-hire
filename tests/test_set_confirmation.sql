BEGIN;
	CREATE SCHEMA IF NOT EXISTS set_confirmation_test;

	CREATE OR REPLACE FUNCTION set_confirmation_test.test_table()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_function('public', 'set_confirmation', ARRAY['text', 'int'], 'should have function');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION set_confirmation_test.test_empty()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT throws_ok('SELECT * FROM set_confirmation(''token-123'')', 'Confirmation token token-123 not found', 'should return error if the confirmation token is not found');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION set_confirmation_test.test_set_confirmation()
	RETURNS SETOF TEXT AS $$
	DECLARE
		local_confirmation_token text;
		out record;
	BEGIN
		PERFORM upsert_email_account('john.doe@mail.com', '12345678', 'John Doe', 'john-doe');
		SELECT confirmation_token
		INTO STRICT local_confirmation_token
		FROM request_confirmation('john.doe@mail.com');

		SELECT *
		INTO STRICT out
		FROM set_confirmation(local_confirmation_token);

		RETURN NEXT is(out.confirmation_token, NULL, 'should reset the confirmation_token column');
		RETURN NEXT is(out.confirmation_sent_at, NULL, 'should reset the confirmation_sent_at column');
		RETURN NEXT is(out.unconfirmed_email, '', 'should reset the unconfirmed_email column');
		RETURN NEXT ok(out.email_verified, 'should set email_verified column to true');
		RETURN NEXT ok(out.confirmed_at IS NOT NULL, 'should set current timestamp to the confirmed_at column');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('set_confirmation_test'::name);

ROLLBACK;
