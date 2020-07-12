BEGIN;
	CREATE SCHEMA IF NOT EXISTS request_confirmation_test;

	CREATE OR REPLACE FUNCTION request_confirmation_test.test_table()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_function('public', 'request_confirmation', ARRAY['text'], 'should have function');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION request_confirmation_test.test_empty()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT throws_ok('SELECT * FROM request_confirmation(''john.doe@mail.com'')', 'Email john.doe@mail.com not found', 'should return error if the email does not exist');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION request_confirmation_test.test_request_confirmation()
	RETURNS SETOF TEXT AS $$
	DECLARE
		out record;
	BEGIN
		PERFORM upsert_email_account('john.doe@mail.com', '12345678', 'John Doe', 'john-doe');
		SELECT *
		INTO STRICT out
		FROM request_confirmation('john.doe@mail.com');

		RETURN NEXT ok(out.confirmation_token IS NOT NULL, 'should set the confirmation_token field');
		RETURN NEXT ok(out.confirmation_sent_at IS NOT NULL, 'should set the confirmation_sent_at field');
		RETURN NEXT ok(out.unconfirmed_email IS NOT NULL, 'should set the unconfirmed_email field');
		RETURN NEXT is(out.unconfirmed_email, 'john.doe@mail.com', 'should set the unconfirmed_email to equal the requested email');
		RETURN NEXT is(out.confirmed_at, null, 'should reset the confirmed_at field');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('request_confirmation_test'::name);

ROLLBACK;
