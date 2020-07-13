package database

import (
	"database/sql"
	"fmt"
	"log"
	"time"

	"github.com/kelseyhightower/envconfig"
	_ "github.com/lib/pq"

	"github.com/gobuffalo/packr/v2"
	migrate "github.com/rubenv/sql-migrate"
)

// Overrides rubenv/sql-migrate default table called "gorp_migrations".
const MigrationTable = "migrations"

func init() {
	migrate.SetTable(MigrationTable)
}

type Config struct {
	User     string `envconfig:"DB_USER" default:"john"`
	Database string `envconfig:"DB_NAME" default:"test"`
	Host     string `envconfig:"DB_HOST" default:"127.0.0.1"`
	Port     int    `envconfig:"DB_PORT" default:"5432"`
	Password string `envconfig:"DB_PASS" default:"123456"`
}

func (c Config) String() string {
	return fmt.Sprintf("postgres://%s:%s@%s:%d/%s?sslmode=disable",
		c.User,
		c.Password,
		c.Host,
		c.Port,
		c.Database,
	)
}

func NewConfig() (*Config, error) {
	var cfg Config
	if err := envconfig.Process("", &cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}

func New() (*sql.DB, error) {
	cfg, err := NewConfig()
	if err != nil {
		return nil, err
	}

	db, err := sql.Open("postgres", cfg.String())
	if err != nil {
		return nil, err
	}

	if err := establishConnection(db); err != nil {
		return nil, err
	}

	// https://www.alexedwards.net/blog/configuring-sqldb
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(25)
	db.SetConnMaxLifetime(5 * time.Minute)
	return db, nil
}

func establishConnection(db *sql.DB) error {
	var err error
	for i := 0; i < 3; i++ {
		err = db.Ping()
		if err != nil {
			log.Printf("[database] Error due to %v. Retrying in 10 seconds\n", err)
			time.Sleep(10 * time.Second)
			continue
		}
		break
	}
	return err
}

func Migrate(db *sql.DB) error {
	migrations := &migrate.PackrMigrationSource{
		Box: packr.New("migrations", "../../migrations"),
	}

	n, err := migrate.Exec(db, "postgres", migrations, migrate.Up)
	log.Printf("[migration] Applied %d migrations\n", n)
	return err
}
