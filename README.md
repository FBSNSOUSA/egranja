# eGranja

Plataforma completa de gestao de granjas avicolas com backend Go, app mobile React Native e dashboard web React.

## Visao Geral

O eGranja conecta **produtores avicolas** e **tecnicos** em uma plataforma integrada para gestao de lotes de frangos de corte, com monitoramento de indicadores zootecnicos, sensores IoT, assistente de IA e rastreabilidade via blockchain.

### Principais Funcionalidades

- **Gestao de Lotes** - Pesagens, mortalidade, racao, agua, ambiencia
- **Indicadores Zootecnicos** - ICA, IEP, GPD, viabilidade com benchmarks Cobb500/Ross308
- **Chat em Tempo Real** - WebSocket entre produtor e tecnico
- **Sanidade** - Vacinacoes, medicamentos com periodo de carencia, controle de visitantes
- **Financeiro** - Custos por categoria, remuneracao, graficos
- **IoT** - Sensores de temperatura, umidade, amonia, CO2, luminosidade, balanca
- **IA Preditiva** - Google Gemini para consultas e analise proativa de indicadores
- **Clima** - Previsao 7 dias com alertas automaticos (Open-Meteo)
- **Rastreabilidade** - Blockchain SHA-256 para certificacao de lotes
- **Offline-First** - WatermelonDB no mobile com sincronizacao automatica
- **Alertas Automaticos** - 10 condicoes monitoradas (mortalidade, peso, agua, temperatura)
- **Relatorios** - Comparativo de lotes, exportacao, graficos

## Arquitetura

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Mobile RN  │────▶│  Backend Go  │◀────│  Web React  │
│  (Expo)     │     │  (Gin/GORM)  │     │  (Vite)     │
└─────────────┘     └──────┬───────┘     └─────────────┘
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        ┌──────────┐ ┌──────────┐ ┌──────────┐
        │PostgreSQL│ │  MinIO   │ │Mosquitto │
        │  15+     │ │  (S3)   │ │  (MQTT)  │
        └──────────┘ └──────────┘ └──────────┘
```

## Stack Tecnologica

| Camada | Tecnologias |
|--------|------------|
| **Backend** | Go 1.22+, Gin, GORM, golang-jwt, gorilla/websocket, paho.mqtt, generative-ai-go |
| **Mobile** | React Native (Expo), TypeScript, Zustand, WatermelonDB, Axios, react-native-maps |
| **Web** | React 19, Vite 7, TypeScript, Tailwind CSS v4, Recharts, React Query |
| **Banco** | PostgreSQL 15+ (UUIDs, pgcrypto) |
| **Storage** | MinIO/S3 (fotos, audio) |
| **Push** | Firebase Cloud Messaging |
| **IA** | Google Gemini API (gemini-2.0-flash) |
| **IoT** | MQTT (Eclipse Mosquitto) |
| **Clima** | Open-Meteo (gratuito) |
| **CI/CD** | GitHub Actions (lint, test, build, docker) |

## Estrutura do Projeto

```
egranja/
├── backend/                    # API Go
│   ├── cmd/server/main.go      # Entrypoint (64 endpoints)
│   ├── internal/
│   │   ├── benchmark/          # Dados Cobb500/Ross308
│   │   ├── config/             # Configuracao via env
│   │   ├── dto/                # Data Transfer Objects
│   │   ├── handler/            # HTTP handlers (20 arquivos)
│   │   ├── middleware/         # JWT, CORS, rate-limit
│   │   ├── model/              # GORM models (26 tabelas)
│   │   ├── repository/        # Camada de dados
│   │   ├── service/           # Logica de negocio
│   │   └── websocket/         # Hub/Client WebSocket
│   ├── migrations/             # SQL (DDL + seed)
│   ├── Dockerfile              # Multi-stage build
│   └── Makefile                # 15 comandos
├── mobile/                     # App React Native
│   └── src/
│       ├── app/                # Navigation (drawer+tabs+stack)
│       ├── components/         # 9 componentes reutilizaveis
│       ├── screens/            # 16 modulos de tela
│       ├── services/           # API, auth, websocket
│       ├── stores/             # Zustand (auth, sync, lote, indicadores)
│       └── theme/              # Cores e tipografia
├── web/                        # Dashboard React
│   └── src/
│       ├── components/         # 7 componentes (Layout, DataTable, etc.)
│       ├── pages/              # 11 paginas
│       ├── hooks/              # useAuth
│       ├── services/           # API client Axios
│       └── types/              # TypeScript interfaces
├── docker/                     # Docker Compose
│   └── docker-compose.yml      # postgres, minio, mosquitto, backend
└── especificacao               # Spec completa (~1700 linhas)
```

## Inicio Rapido

### Pre-requisitos

- Go 1.22+
- Node.js 20+
- Docker e Docker Compose
- PostgreSQL 15+ (ou use via Docker)

### 1. Clonar o repositorio

```bash
git clone git@github.com:FBSNSOUSA/egranja.git
cd egranja
```

### 2. Configurar variaveis de ambiente

```bash
cp backend/.env.example backend/.env
# Edite backend/.env com suas chaves (Gemini, Firebase, etc.)
```

### 3. Subir infraestrutura com Docker

```bash
cd backend
make docker-up
```

Isso sobe PostgreSQL, MinIO, Mosquitto e o backend.

### Credenciais dos servicos (ambiente Docker local)

| Servico | URL / Porta | Usuario | Senha |
|---------|--------------|---------|--------|
| **MinIO** (API) | http://localhost:9000 | `minioadmin` | `minioadmin` |
| **MinIO** (Console web) | http://localhost:9001 | `minioadmin` | `minioadmin` |
| **Mosquitto** (MQTT) | localhost:1883 (MQTT), 9883 (WebSocket) | Em desenvolvimento: acesso anonimo (sem usuario/senha) | — |

Para alterar as credenciais do MinIO, defina `MINIO_ROOT_USER` e `MINIO_ROOT_PASSWORD` no ambiente antes de subir o Docker.

```bash
make migrate
make seed  # dados iniciais (opcional)
```

### 5. Rodar o backend (modo dev)

```bash
make run
# Servidor em http://localhost:8080
```

### 6. Rodar o mobile

```bash
cd mobile
npm install
npx expo start
```

### 7. Rodar o dashboard web

```bash
cd web
npm install
npm run dev
# Dashboard em http://localhost:5173
```

## API Endpoints

O backend expoe **64 endpoints** organizados por dominio:

| Grupo | Endpoints | Descricao |
|-------|-----------|-----------|
| Auth | `POST /login`, `/register`, `/refresh` | Autenticacao JWT |
| Granjas | CRUD + `/granjas/:id/clima` | Gestao de granjas |
| Galpoes | CRUD + mapa | Galpoes com GPS e orientacao |
| Lotes | CRUD + `/finalizar` | Ciclo completo do lote |
| Pesagens | CRUD + items | Pesagens com amostragem |
| Mortalidade | CRUD | Registro diario |
| Racao | Tipos + recebimento + consumo | Controle de alimentacao |
| Agua | CRUD | Consumo hidrico |
| Ambiencia | CRUD | Registros ambientais |
| Checklist | CRUD | Checklist diario adaptativo |
| Sanidade | Vacinas + medicamentos + visitantes | Controle sanitario |
| Financeiro | Custos + remuneracao | Gestao financeira |
| Chat/WS | WebSocket + mensagens | Chat em tempo real |
| Alertas | GET automaticos | 10 condicoes monitoradas |
| IA | Consultar + analisar | Gemini 2.0 Flash |
| IoT | Readings + historico | Sensores MQTT |
| Clima | Previsao + alertas | Open-Meteo 7 dias |
| Blockchain | Cadeia + verificar + certificado | Rastreabilidade |
| Indicadores | Calculos zootecnicos | ICA, IEP, GPD |
| Relatorios | Gerar + comparativo | Exportacao |
| Upload | Fotos + audio | MinIO/S3 |
| WhatsApp | Envio de relatorios | Notificacoes |
| Sync | Mobile offline sync | WatermelonDB |

## Testes

```bash
cd backend
make test           # 96 testes
make test-coverage  # com relatorio HTML
```

Cobertura inclui: auth, indicadores, blockchain, alertas, clima, middleware, handlers, benchmarks e config.

## Comandos do Makefile

```
make run            - Servidor em modo dev
make build          - Compila binario otimizado
make test           - Executa 96 testes
make test-coverage  - Testes com relatorio HTML
make lint           - Linter (golangci-lint)
make fmt            - Formata codigo
make migrate        - Executa migrations SQL
make seed           - Carga inicial de dados
make swagger        - Gera docs OpenAPI
make docker-up      - Sobe containers
make docker-down    - Para containers
make docker-reset   - Para e remove volumes
make docker-logs    - Logs dos containers
make clean          - Remove artefatos de build
make tools          - Instala ferramentas de dev
```

## Tipos de Usuario

| Tipo | Acesso | Funcionalidades |
|------|--------|----------------|
| **Produtor** | Mobile + Web | Gestao dos seus lotes, galpoes e granjas |
| **Tecnico** | Mobile + Web | Acompanha multiplos produtores vinculados |
| **Admin** | Web | Dashboard completo, gestao de usuarios |

## Licenca

Projeto privado - todos os direitos reservados.
