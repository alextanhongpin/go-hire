// Code generated by sqlc. DO NOT EDIT.

package entity

import (
	"database/sql"
	"encoding/json"
	"net"
	"time"

	"github.com/google/uuid"
)

type Provider string

const (
	ProviderEmail    Provider = "email"
	ProviderPhone    Provider = "phone"
	ProviderFacebook Provider = "facebook"
	ProviderGoogle   Provider = "google"
)

func (e *Provider) Scan(src interface{}) error {
	*e = Provider(src.([]byte))
	return nil
}

type Account struct {
	ID uuid.UUID `json:"id"`
	// The id of the provider, e.g for email provider, the id is the email, for other provider the id is the unique id of the provider
	Uid string `json:"uid"`
	// One of email, facebook, google etc
	Provider Provider `json:"provider"`
	// The encrypted password if the provider is Email, otherwise the access token of the provider
	Token string `json:"token"`
	// The owner of the account - one user can have many accounts with the same provider, but with unique provider id
	UserID uuid.UUID `json:"user_id"`
	// The email of the provider - allows linking of account by similar email to be done
	Email     string          `json:"email"`
	Data      json.RawMessage `json:"data"`
	CreatedAt time.Time       `json:"created_at"`
	UpdatedAt time.Time       `json:"updated_at"`
	DeletedAt sql.NullTime    `json:"deleted_at"`
}

type Slug struct {
	ID      int32  `json:"id"`
	Name    string `json:"name"`
	Counter int32  `json:"counter"`
}

type User struct {
	ID                  uuid.UUID      `json:"id"`
	Email               sql.NullString `json:"email"`
	EmailVerified       bool           `json:"email_verified"`
	PhoneNumber         string         `json:"phone_number"`
	PhoneNumberVerified bool           `json:"phone_number_verified"`
	Name                string         `json:"name"`
	FamilyName          string         `json:"family_name"`
	GivenName           string         `json:"given_name"`
	MiddleName          string         `json:"middle_name"`
	Nickname            string         `json:"nickname"`
	PreferredUsername   string         `json:"preferred_username"`
	// URL of the End-User's profile page
	Profile string `json:"profile"`
	Picture string `json:"picture"`
	// URL of the End-User's Web page or blog
	Website string `json:"website"`
	// End-User's gender (m|f|o|x)
	Gender string `json:"gender"`
	// End-User's birthday, represented as an ISO 8601:2004 [ISO8601?2004] YYYY-MM-DD format. The year MAY be 0000, indicating that it is omitted
	Birthdate sql.NullTime `json:"birthdate"`
	// String from zoneinfo [zoneinfo] time zone database representing the End-User's time zone. For example, Europe/Paris or America/Los_Angeles
	Zoneinfo string `json:"zoneinfo"`
	// End-User's locale, represented as a BCP47 [RFC5646] language tag. This is typically an ISO 639-1 Alpha-2 [ISO639?1] language code in lowercase and an ISO 3166-1 Alpha-2 [ISO3166?1] country code in uppercase, separated by a dash. For example, en-US or fr-CA. As a compatibility note, some implementations have used an underscore as the separator rather than a dash, for example, en_US
	Locale string `json:"locale"`
	// Full street address component, which MAY include house number, street name, Post Office Box, and multi-line extended street address information. This field MAY contain multiple lines, separated by newlines. Newlines can be represented either as a carriage return/line feed pair ("\r\n") or as a single line feed character ("\n").
	StreetAddress string `json:"street_address"`
	// City or locality component.
	Locality string `json:"locality"`
	// State, province, prefecture or region component.
	Region string `json:"region"`
	// Zip code or postal code component.
	PostalCode string `json:"postal_code"`
	// Country name component.
	Country                string         `json:"country"`
	ConfirmationToken      sql.NullString `json:"confirmation_token"`
	ConfirmationSentAt     sql.NullTime   `json:"confirmation_sent_at"`
	ConfirmedAt            sql.NullTime   `json:"confirmed_at"`
	UnconfirmedEmail       string         `json:"unconfirmed_email"`
	ResetPasswordToken     sql.NullString `json:"reset_password_token"`
	ResetPasswordSentAt    sql.NullTime   `json:"reset_password_sent_at"`
	AllowPasswordChange    bool           `json:"allow_password_change"`
	SignInCount            int32          `json:"sign_in_count"`
	CurrentSignInAt        sql.NullTime   `json:"current_sign_in_at"`
	CurrentSignInIp        net.IP         `json:"current_sign_in_ip"`
	CurrentSignInUserAgent string         `json:"current_sign_in_user_agent"`
	LastSignInAt           sql.NullTime   `json:"last_sign_in_at"`
	LastSignInIp           net.IP         `json:"last_sign_in_ip"`
	LastSignInUserAgent    string         `json:"last_sign_in_user_agent"`
	LastSignOutAt          sql.NullTime   `json:"last_sign_out_at"`
	LastSignOutIp          net.IP         `json:"last_sign_out_ip"`
	LastSignOutUserAgent   string         `json:"last_sign_out_user_agent"`
	CreatedAt              time.Time      `json:"created_at"`
	UpdatedAt              time.Time      `json:"updated_at"`
	DeletedAt              sql.NullTime   `json:"deleted_at"`
}
