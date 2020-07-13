package repository

import (
	"context"
	"database/sql"
	"encoding/json"

	"github.com/alextanhongpin/go-db/entity"
	"github.com/alextanhongpin/go-db/pkg/database"
)

type Auth struct {
	db    *sql.DB
	stmts database.Statements
}

func NewAuth(db *sql.DB) (*Auth, error) {
	stmts, err := database.Prepare(db, raw)
	if err != nil {
		return nil, err
	}
	return &Auth{
		db:    db,
		stmts: stmts,
	}, nil
}

type UpsertEmailAccountParams struct {
	Email    string
	Password string
	Name     string
	Slug     string
}

func (a *Auth) UpsertEmailAccount(ctx context.Context, params UpsertEmailAccountParams) (entity.Account, error) {
	stmt := a.stmts[upsertEmailAccount]
	row := stmt.QueryRowContext(ctx, params.Email, params.Password, params.Name, params.Slug)
	return scanAccount(row)
}

type UpsertSocialAccountParams struct {
	Provider entity.Provider
	UID      string
	Email    string
	Name     string
	Slug     string
	Data     json.RawMessage
	Token    string
}

func (a *Auth) UpsertSocialAccount(ctx context.Context, params UpsertSocialAccountParams) (entity.Account, error) {
	stmt := a.stmts[upsertSocialAccount]
	row := stmt.QueryRowContext(ctx,
		params.Provider,
		params.UID,
		params.Email,
		params.Name,
		params.Slug,
		params.Data,
		params.Token,
	)
	return scanAccount(row)
}

type AuthenticateParams struct {
	Email    string
	Password string
}

func (a *Auth) Authenticate(ctx context.Context, params AuthenticateParams) (entity.User, error) {
	stmt := a.stmts[authenticate]

	row := stmt.QueryRowContext(ctx, params.Email, params.Password)
	return scanUser(row)
}

type AuthorizeParams struct {
	Provider entity.Provider
	UID      string
}

func (a *Auth) Authorize(ctx context.Context, params AuthorizeParams) (entity.User, error) {
	stmt := a.stmts[authorize]

	row := stmt.QueryRowContext(ctx, params.Provider, params.UID)
	return scanUser(row)
}

func (a *Auth) RequestConfirmation(ctx context.Context, email string) (string, error) {
	stmt := a.stmts[requestConfirmation]
	row := stmt.QueryRowContext(ctx, email)
	var i string
	err := row.Scan(&i)
	return i, err
}

func (a *Auth) SetConfirmation(ctx context.Context, token string) (entity.User, error) {
	stmt := a.stmts[setConfirmation]
	row := stmt.QueryRowContext(ctx, token)
	return scanUser(row)
}

func (a *Auth) RequestResetPassword(ctx context.Context, email string) (string, error) {
	stmt := a.stmts[requestResetPassword]
	row := stmt.QueryRowContext(ctx, email)
	var i string
	err := row.Scan(&i)
	return i, err
}

type ResetPasswordParams struct {
	Token    string
	Password string
}

func (a *Auth) ResetPassword(ctx context.Context, params ResetPasswordParams) (entity.User, error) {
	stmt := a.stmts[setConfirmation]
	row := stmt.QueryRowContext(ctx, params.Token, params.Password)
	return scanUser(row)
}

func scanUser(row *sql.Row) (entity.User, error) {
	var i entity.User
	err := row.Scan(
		&i.ID,
		&i.Email,
		&i.EmailVerified,
		&i.PhoneNumber,
		&i.PhoneNumberVerified,
		&i.Name,
		&i.FamilyName,
		&i.GivenName,
		&i.MiddleName,
		&i.Nickname,
		&i.PreferredUsername,
		&i.Profile,
		&i.Picture,
		&i.Website,
		&i.Gender,
		&i.Birthdate,
		&i.Zoneinfo,
		&i.Locale,
		&i.StreetAddress,
		&i.Locality,
		&i.Region,
		&i.PostalCode,
		&i.Country,
		&i.ConfirmationToken,
		&i.ConfirmationSentAt,
		&i.ConfirmedAt,
		&i.UnconfirmedEmail,
		&i.ResetPasswordToken,
		&i.ResetPasswordSentAt,
		&i.AllowPasswordChange,
		&i.SignInCount,
		&i.CurrentSignInAt,
		&i.CurrentSignInIp,
		&i.CurrentSignInUserAgent,
		&i.LastSignInAt,
		&i.LastSignInIp,
		&i.LastSignInUserAgent,
		&i.LastSignOutAt,
		&i.LastSignOutIp,
		&i.LastSignOutUserAgent,
		&i.CreatedAt,
		&i.UpdatedAt,
		&i.DeletedAt,
	)
	return i, err
}

func scanAccount(row *sql.Row) (entity.Account, error) {
	var i entity.Account
	err := row.Scan(
		&i.ID,
		&i.Uid,
		&i.Provider,
		&i.Token,
		&i.UserID,
		&i.Email,
		&i.Data,
		&i.CreatedAt,
		&i.UpdatedAt,
		&i.DeletedAt,
	)
	return i, err
}
