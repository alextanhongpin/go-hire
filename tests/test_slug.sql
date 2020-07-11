BEGIN;
	CREATE SCHEMA IF NOT EXISTS slug_test;

	CREATE OR REPLACE FUNCTION slug_test.test_table()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT has_table('public', 'slug', 'should return table');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION slug_test.test_empty()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT throws_ok('SELECT unique_slug('''')', '23514', 'new row for relation "slug" violates check constraint "slug_name_check"', 'should return error when slug is empty');
	END;
	$$ LANGUAGE plpgsql;


	CREATE OR REPLACE FUNCTION slug_test.test_duplicate()
	RETURNS SETOF TEXT AS $$
	BEGIN
		RETURN NEXT is(unique_slug('john'), 'john', 'should return john');
		RETURN NEXT is(unique_slug('john'), 'john-1', 'should return john-1');
		RETURN NEXT is(unique_slug('john'), 'john-2', 'should return john-2');
	END;
	$$ LANGUAGE plpgsql;

	SELECT * FROM runtests('slug_test'::name);

ROLLBACK;
