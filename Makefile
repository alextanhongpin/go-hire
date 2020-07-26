-include .env
export

include pkg/database/Makefile

up:
	@docker-compose up -d

down:
	@docker-compose down

exec:
	@docker exec -it $(shell docker ps -q) bash

# Runs pg_prove for all files ending with .sql (default .pg) in the tests/ folder.
.PHONY: tests
tests:
	@docker exec -it $(shell docker ps -q) pg_prove -U ${DB_USER} -d ${DB_NAME} --verbose --ext .sql -r tmp/tests/

VERSION := 12.3-alpine

docker:
	docker build -t alextanhongpin/pg-tap:${VERSION} --build-arg POSTGRES_VERSION=${VERSION} .

push:
	docker push alextanhongpin/pg-tap:${VERSION}

dockerhub: docker push
