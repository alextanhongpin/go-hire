package repository

import (
	"github.com/alextanhongpin/go-db/pkg/database"
)

const (
	upsertEmailAccount database.ID = iota
	upsertSocialAccount
	authenticate
	authorize
	requestConfirmation
	setConfirmation
	requestResetPassword
	resetPassword
)

var raw = database.Raw{
	upsertEmailAccount: `
		-- $1: email, text
		-- $2: password, text
		-- $3: name, text
		-- $4: slug, text

		SELECT *
		FROM upsert_email_account($1, $2, $3, $4)
	`,
	upsertSocialAccount: `
		-- $1: provider, provider
		-- $2: uid, text
		-- $3: email, text
		-- $4: name, text
		-- $5: slug, text
		-- $6: data, jsonb
		-- $7: token, text

		SELECT *
		FROM upsert_social_account($1, $2, $3, $4, $5, $6, $7);
	`,

	authenticate: `
		-- $1: email, text
		-- $2: password, text

		SELECT *
		FROM authenticate($1, $2);
	`,
	authorize: `
		-- $1: provider, provider
		-- $2: uid, text

		SELECT *
		FROM authorize($1, $2)
	`,

	requestConfirmation: `
		-- $1: email, text

		WITH confirmation_requested AS (
			SELECT *
			FROM request_confirmation($1)
		)
		SELECT COALESCE(
			pg_notify('confirmation_requested', row_to_json(confirmation_requested.*)::text)::text,
			confirmation_token
		)
		FROM confirmation_requested
	`,
	setConfirmation: `
		-- $1: token, text

		SELECT *
		FROM set_confirmation($1, 24);
	`,
	requestResetPassword: `
		-- $1: email, text

		WITH reset_password_requested AS (
			SELECT *
			FROM request_reset_password($1)
		)
		SELECT COALESCE(
			pg_notify('reset_password_requested', row_to_json(reset_password_requested.*)::text)::text,
			reset_password_token
		)
		FROM reset_password_requested
	`,
	resetPassword: `
		-- $1: token, text
		-- $2: password, text

		SELECT *
		FROM reset_password($1, $2, 24)
	`,
}
