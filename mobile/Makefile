# =============================================================
# eGranja Mobile - Makefile
# =============================================================

.PHONY: dev android ios web tunnel clear \
        build-apk build-aab build-ios build-dev build-local prebuild \
        emulator emulator-create emulator-wipe devices \
        lint typecheck test test-watch test-coverage check \
        infra-up infra-down infra-logs infra-reset fullstack \
        setup doctor clean clean-deep deps-update info help

.DEFAULT_GOAL := help

# Carrega .env se existir
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# ---- Variaveis ----
DOCKER_COMPOSE=docker compose -f ../docker/docker-compose.yml

# =============================================================
# DESENVOLVIMENTO
# =============================================================

## Inicia servidor Expo dev
dev:
	npx expo start

## Inicia no emulador Android
android:
	npx expo start --android

## Inicia no simulador iOS
ios:
	npx expo start --ios

## Inicia versao web
web:
	npx expo start --web

## Inicia com tunnel (dispositivos remotos)
tunnel:
	npx expo start --tunnel

## Inicia com cache limpo
clear:
	npx expo start --clear

# =============================================================
# BUILD / COMPILACAO
# =============================================================

## Build APK via EAS (preview - teste interno)
build-apk:
	@echo "Iniciando build APK via EAS Cloud..."
	@if ! command -v eas >/dev/null 2>&1; then \
		echo ""; \
		echo "EAS CLI nao encontrado. Instalando..."; \
		npm install -g eas-cli; \
	fi
	npx eas build --platform android --profile preview

## Build AAB via EAS (producao - Google Play)
build-aab:
	@echo "Iniciando build AAB via EAS Cloud..."
	npx eas build --platform android --profile production

## Build iOS via EAS (requer conta Apple Developer)
build-ios:
	@echo "Iniciando build iOS via EAS Cloud..."
	npx eas build --platform ios --profile production

## Build development client via EAS
build-dev:
	@echo "Iniciando build development client..."
	npx eas build --platform android --profile development

## Build APK local (requer Android SDK + Java)
build-local:
	@if [ -z "$(ANDROID_HOME)" ]; then \
		echo "ERRO: ANDROID_HOME nao definido."; \
		echo "Execute 'make doctor' para verificar pre-requisitos."; \
		exit 1; \
	fi
	@if ! command -v java >/dev/null 2>&1; then \
		echo "ERRO: Java JDK nao encontrado."; \
		echo "Instale JDK 17+: sudo apt install openjdk-17-jdk"; \
		exit 1; \
	fi
	@echo "Gerando projeto nativo e compilando localmente..."
	npx expo prebuild --clean
	cd android && ./gradlew assembleRelease
	@echo ""
	@echo "APK gerado em: android/app/build/outputs/apk/release/"

## Gera android/ e ios/ (expo prebuild)
prebuild:
	@echo "AVISO: Isto gera diretorios android/ e ios/ no projeto."
	npx expo prebuild

# =============================================================
# EMULADOR
# =============================================================

## Lista e inicia emulador Android
emulator:
	@if [ -z "$(ANDROID_HOME)" ]; then \
		echo "ERRO: ANDROID_HOME nao definido."; \
		echo "Execute 'make doctor' para verificar pre-requisitos."; \
		exit 1; \
	fi
	@AVDS=$$($(ANDROID_HOME)/emulator/emulator -list-avds 2>/dev/null); \
	if [ -z "$$AVDS" ]; then \
		echo "Nenhum AVD encontrado."; \
		echo "Execute 'make emulator-create' para criar um."; \
		exit 1; \
	fi; \
	echo "AVDs disponiveis:"; \
	echo "$$AVDS"; \
	echo ""; \
	FIRST=$$(echo "$$AVDS" | head -1); \
	echo "Iniciando: $$FIRST"; \
	$(ANDROID_HOME)/emulator/emulator -avd "$$FIRST" &

## Cria AVD Pixel 6 API 34
emulator-create:
	@if [ -z "$(ANDROID_HOME)" ]; then \
		echo "ERRO: ANDROID_HOME nao definido."; \
		exit 1; \
	fi
	@echo "Baixando imagem do sistema..."
	$(ANDROID_HOME)/cmdline-tools/latest/bin/sdkmanager "system-images;android-34;google_apis;x86_64"
	@echo "Criando AVD Pixel_6_API_34..."
	echo "no" | $(ANDROID_HOME)/cmdline-tools/latest/bin/avdmanager create avd \
		-n Pixel_6_API_34 \
		-k "system-images;android-34;google_apis;x86_64" \
		-d "pixel_6"
	@echo "AVD criado com sucesso! Execute 'make emulator' para iniciar."

## Inicia emulador com dados limpos
emulator-wipe:
	@FIRST=$$($(ANDROID_HOME)/emulator/emulator -list-avds 2>/dev/null | head -1); \
	if [ -z "$$FIRST" ]; then \
		echo "Nenhum AVD encontrado."; \
		exit 1; \
	fi; \
	echo "Iniciando $$FIRST com wipe-data..."; \
	$(ANDROID_HOME)/emulator/emulator -avd "$$FIRST" -wipe-data &

## Lista dispositivos conectados (adb)
devices:
	adb devices -l

# =============================================================
# QUALIDADE
# =============================================================

## Executa ESLint
lint:
	npx eslint . --ext .ts,.tsx --max-warnings 0

## Verifica tipos TypeScript
typecheck:
	npx tsc --noEmit

## Executa testes Jest
test:
	npx jest

## Testes em modo watch
test-watch:
	npx jest --watch

## Testes com cobertura
test-coverage:
	npx jest --coverage

## Executa lint + typecheck + test
check: lint typecheck test

# =============================================================
# INFRAESTRUTURA
# =============================================================

## Sobe backend + banco (Docker)
infra-up:
	$(DOCKER_COMPOSE) up -d --build

## Para infraestrutura Docker
infra-down:
	$(DOCKER_COMPOSE) down

## Exibe logs dos containers
infra-logs:
	$(DOCKER_COMPOSE) logs -f

## Para e remove volumes (CUIDADO: apaga dados!)
infra-reset:
	@echo "ATENCAO: Isto vai apagar todos os dados (banco, storage, etc)!"
	@echo "Pressione Ctrl+C para cancelar ou Enter para continuar..."
	@read _
	$(DOCKER_COMPOSE) down -v

## Sobe infra + inicia app mobile
fullstack: infra-up
	@echo "Aguardando infraestrutura subir..."
	@sleep 5
	npx expo start

# =============================================================
# SETUP / UTILITARIOS
# =============================================================

## Instala dependencias e configura ambiente
setup:
	@echo "Instalando dependencias..."
	npm install
	@if [ ! -f .env ]; then \
		echo "Criando .env a partir do .env.example..."; \
		cp .env.example .env; \
		echo ".env criado. Ajuste os valores conforme necessario."; \
	else \
		echo ".env ja existe, mantendo configuracao atual."; \
	fi
	@if ! command -v eas >/dev/null 2>&1; then \
		echo "Instalando EAS CLI..."; \
		npm install -g eas-cli; \
	fi
	@echo ""
	@echo "Setup concluido! Execute 'make doctor' para verificar pre-requisitos."

## Verifica pre-requisitos instalados
doctor:
	@bash scripts/doctor.sh

## Remove caches e node_modules
clean:
	@echo "Limpando caches..."
	rm -rf node_modules/.cache .expo dist
	@echo "Removendo node_modules..."
	rm -rf node_modules
	@echo "Limpeza concluida. Execute 'make setup' para reinstalar."

## Limpeza profunda (inclui npm cache)
clean-deep: clean
	npm cache clean --force
	rm -rf package-lock.json
	@echo "Limpeza profunda concluida."

## Verifica versoes de dependencias Expo
deps-update:
	npx expo install --check

## Exibe configuracao Expo resolvida
info:
	npx expo config

## Exibe esta ajuda
help:
	@echo ""
	@echo "  eGranja Mobile - Comandos Disponiveis"
	@echo "  ======================================"
	@echo ""
	@echo "  DESENVOLVIMENTO:"
	@echo "    make dev              Inicia servidor Expo dev"
	@echo "    make android          Inicia no emulador Android"
	@echo "    make ios              Inicia no simulador iOS"
	@echo "    make web              Inicia versao web"
	@echo "    make tunnel           Inicia com tunnel (dispositivos remotos)"
	@echo "    make clear            Inicia com cache limpo"
	@echo ""
	@echo "  BUILD / COMPILACAO:"
	@echo "    make build-apk        Build APK via EAS (preview)"
	@echo "    make build-aab        Build AAB via EAS (producao)"
	@echo "    make build-ios        Build iOS via EAS"
	@echo "    make build-dev        Build development client via EAS"
	@echo "    make build-local      Build APK local (requer Android SDK)"
	@echo "    make prebuild         Gera android/ e ios/ (expo prebuild)"
	@echo ""
	@echo "  EMULADOR:"
	@echo "    make emulator         Lista e inicia emulador Android"
	@echo "    make emulator-create  Cria AVD Pixel 6 API 34"
	@echo "    make emulator-wipe    Inicia emulador com dados limpos"
	@echo "    make devices          Lista dispositivos conectados (adb)"
	@echo ""
	@echo "  QUALIDADE:"
	@echo "    make lint             Executa ESLint"
	@echo "    make typecheck        Verifica tipos TypeScript"
	@echo "    make test             Executa testes Jest"
	@echo "    make test-watch       Testes em modo watch"
	@echo "    make test-coverage    Testes com cobertura"
	@echo "    make check            Executa lint + typecheck + test"
	@echo ""
	@echo "  INFRAESTRUTURA:"
	@echo "    make infra-up         Sobe backend + banco (Docker)"
	@echo "    make infra-down       Para infraestrutura Docker"
	@echo "    make infra-logs       Exibe logs dos containers"
	@echo "    make infra-reset      Para e remove volumes (CUIDADO!)"
	@echo "    make fullstack        Sobe infra + inicia app"
	@echo ""
	@echo "  SETUP / UTILITARIOS:"
	@echo "    make setup            Instala deps e configura ambiente"
	@echo "    make doctor           Verifica pre-requisitos"
	@echo "    make clean            Remove caches e node_modules"
	@echo "    make clean-deep       Limpeza profunda (inclui npm cache)"
	@echo "    make deps-update      Verifica versoes de deps Expo"
	@echo "    make info             Exibe config Expo resolvida"
	@echo ""
