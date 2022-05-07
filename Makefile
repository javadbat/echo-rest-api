ifneq (,$(wildcard ./.env))
    include .env
    export
endif

migration-create:
	migrate create -ext sql -dir migrations/sql $(name)

migration-up:
	migrate -path migrations/sql -verbose -database "${DATABASE_URL}" up

migration-down:
	migrate -path migrations/sql -verbose -database "${DATABASE_URL}" down

run-db:
	docker compose up postgres redis

run-api:
	go run ./cmd/api/

build-api:
	go build -v -o ./bin/ ./cmd/api

test:
	go test -v -cover -benchmem ./...

mock:
	mockery --all

setup:
	go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest 

git-hooks:
	echo "Installing hooks..." && \
	rm -rf .git/hooks/pre-commit && \
	ln -s ../../tools/scripts/pre-commit.sh .git/hooks/pre-commit && \
	chmod +x .git/hooks/pre-commit && \
	echo "Done!"

tools:
	go run ./tools/modtool/

routes:
	go run ./tools/routes/

.PHONY:
	migration-create
	migration-up
	migration-down
	run-api
	run-db
	build-api
	test
	mock
	setup
	tools
	routes