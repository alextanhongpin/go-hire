DBCONFIG_PATH := ./pkg/database/dbconfig.yml

MODULES := go.mod go.sum

$(MODULES):
	@go get ./...
	@go mod tidy

install: $(MODULES) ## Install required dependencies
	@# For migration.
	@go get -u -v github.com/rubenv/sql-migrate/...

	@# Library installation.
	@go get -u github.com/gobuffalo/packr/v2/...

	@# Binary installation.
	@go get -u github.com/gobuffalo/packr/v2/packr2

sql-%: ## Creates a new migration
	@sql-migrate new -config=${DBCONFIG_PATH} $*

migrate: ## Run the migration
	@sql-migrate up -config=${DBCONFIG_PATH}

rollback: ## Undo the last migration
	@sql-migrate down -config=${DBCONFIG_PATH}

gen: ## Generate packr migration bindata.
	@# packr2 clean
	@packr2
	@sqlc generate
