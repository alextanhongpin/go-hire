# PgTap

Unit testing for postgres. Full documentation [here](https://pgtap.org/documentation.html).

```bash
$ make tests
```

## Why unit testing in Postgres?

- write SQL to test SQL!
- testing roles/functions is easier
- your playground to verify if things works, and serve as a documentation too

## Faster postgres testing

Set the following in `postgresql.conf`:
```
fsync = off
full_page_writes = off
```

To understand the implications, read [here](https://www.postgresql.org/docs/8.1/runtime-config-wal.html#:~:text=If%20you%20trust%20your%20operating,also%20consider%20turning%20off%20full_page_writes.).

## Auth

```sql
-- Find all functions.
select n.nspname as function_schema,
       p.proname as function_name,
       l.lanname as function_language,
       case when l.lanname = 'internal' then p.prosrc
            else pg_get_functiondef(p.oid)
            end as definition,
       pg_get_function_arguments(p.oid) as function_arguments,
       t.typname as return_type
from pg_proc p
left join pg_namespace n on p.pronamespace = n.oid
left join pg_language l on p.prolang = l.oid
left join pg_type t on t.oid = p.prorettype
where n.nspname not in ('pg_catalog', 'information_schema')
AND p.proname like '%auth%'
order by function_schema,
         function_name;

select routine_name, routine_definition
from information_schema.routines
where routine_schema = 'public'
and data_type = 'USER-DEFINED';

-- Slug.
select unique_slug('your-slug');

-- Factory.
select * from upsert_email_account('your-email', 'your-password', 'your-name', 'your-slug');
select * from upsert_social_account('facebook|google', uid, email, name, slug, '{}'::jsonb, token);

-- Authn/authz.
select encrypt_password('your-password', minlength=6, cost=12);
select compare_password('your-password', 'encrypted-password');
select * from authenticate(email, password);
select * from authorize('facebook|google', uid);

-- Confirm password utility.
select confirm_password_token from request_confirmation(email);
select * from set_confirmation(token, confirm_within_hours=24);

-- Reset password utility;
select reset_password_token from request_reset_password(email);
select * from reset_password(token, plaintext_password, reset_within_hours=24);
```
