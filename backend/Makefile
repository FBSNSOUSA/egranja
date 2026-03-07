# =============================================================
# eGranja Backend - Makefile
# =============================================================

.PHONY: run build test lint migrate seed swagger docker-up docker-down clean help

# Carrega .env se existir
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# ---- Variaveis ----
BINARY_NAME=egranja
MAIN_PATH=cmd/server/main.go
BUILD_DIR=bin
DOCKER_COMPOSE=docker compose -f ../docker/docker-compose.yml

# ---- Desenvolvimento ----

## Executa o servidor em modo desenvolvimento
run:
	go run $(MAIN_PATH)

## Compila o binario
build:
	@mkdir -p $(BUILD_DIR)
	CGO_ENABLED=0 go build -ldflags="-w -s" -o $(BUILD_DIR)/$(BINARY_NAME) $(MAIN_PATH)

## Executa todos os testes
test:
	go test ./... -v -cover

## Executa testes com relatorio de cobertura
test-coverage:
	go test ./... -coverprofile=coverage.out
	go tool cover -html=coverage.out -o coverage.html
	@echo "Relatorio de cobertura gerado em coverage.html"

## Executa o linter
lint:
	golangci-lint run ./...

## Formata o codigo
fmt:
	go fmt ./...
	goimports -w .

# ---- Banco de Dados ----

## Executa as migrations SQL
migrate:
	@echo "Executando migrations..."
	@for f in migrations/*.sql; do \
		echo "Aplicando $$f..."; \
		psql "$(DATABASE_URL)" -f "$$f"; \
	done
	@echo "Migrations concluidas."

## Executa o seed SQL de carga inicial
seed:
	@echo "Executando seed..."
	@if [ -f migrations/seed.sql ]; then \
		psql "$(DATABASE_URL)" -f migrations/seed.sql; \
		echo "Seed concluido."; \
	else \
		echo "Arquivo migrations/seed.sql nao encontrado."; \
	fi

# ---- Documentacao ----

## Gera documentacao Swagger/OpenAPI
swagger:
	swag init -g $(MAIN_PATH) -o docs --parseDependency --parseInternal

# ---- Docker ----

## Sobe todos os containers
docker-up:
	$(DOCKER_COMPOSE) up -d --build

## Para todos os containers
docker-down:
	$(DOCKER_COMPOSE) down

## Para e remove volumes (CUIDADO: apaga dados!)
docker-reset:
	$(DOCKER_COMPOSE) down -v

## Exibe logs dos containers
docker-logs:
	$(DOCKER_COMPOSE) logs -f

# ---- Utilitarios ----

## Remove artefatos de build
clean:
	rm -rf $(BUILD_DIR) coverage.out coverage.html

## Instala ferramentas de desenvolvimento
tools:
	go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
	go install github.com/swaggo/swag/cmd/swag@latest
	go install golang.org/x/tools/cmd/goimports@latest

## Exibe esta ajuda
help:
	@echo "Comandos disponiveis:"
	@echo ""
	@echo "  make run            - Executa o servidor em modo dev"
	@echo "  make build          - Compila o binario"
	@echo "  make test           - Executa os testes"
	@echo "  make test-coverage  - Testes com relatorio de cobertura"
	@echo "  make lint           - Executa o linter"
	@echo "  make fmt            - Formata o codigo"
	@echo "  make migrate        - Executa migrations SQL"
	@echo "  make seed           - Executa seed de carga inicial"
	@echo "  make swagger        - Gera docs Swagger"
	@echo "  make docker-up      - Sobe containers Docker"
	@echo "  make docker-down    - Para containers Docker"
	@echo "  make docker-reset   - Para e remove volumes"
	@echo "  make docker-logs    - Exibe logs dos containers"
	@echo "  make clean          - Remove artefatos de build"
	@echo "  make tools          - Instala ferramentas de dev"
	@echo ""
