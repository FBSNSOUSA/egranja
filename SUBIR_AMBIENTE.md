# eGranja - Subir ambiente para teste

## Subir tudo com Docker (backend + web)

Na raiz do projeto:

```bash
docker compose -f docker/docker-compose.yml up -d
```

Isso sobe:
- **PostgreSQL** (porta 5433)
- **MinIO** (9000, 9001)
- **Mosquitto** (1883, 9883)
- **Backend API** (porta 8080)
- **Dashboard web** (porta 3000)

**Acessos:**
- Dashboard: **http://localhost:3000**
- API: **http://localhost:8080** (health: http://localhost:8080/health)

**Logins de teste (criados pelo seed):**

| Login    | Senha       | Tipo     |
|----------|-------------|----------|
| `tecnico` | `tecnico123` | técnico  |
| `produtor` | `produtor123` | produtor |

O técnico está vinculado ao produtor (pode ver seus lotes).

As migrations já foram aplicadas (001, 002_seed, 003). Se subir o stack do zero (novo volume), rode as migrations manualmente (veja seção "Migrations" abaixo).

---

## O que já está pronto (ajustes feitos)

- **backend/.env** criado com `DATABASE_URL` em `localhost:5433`.
- **docker-compose**: PostgreSQL na porta **5433** (evitar conflito com outro Postgres na 5432).
- **Mosquitto**: `allow_anonymous true` em desenvolvimento.
- **Backend**: Dockerfile com Go 1.24; healthcheck em `/health`.
- **Web**: serviço no Docker com proxy para o backend; porta 3000.
- **Mobile**: lê `EXPO_PUBLIC_API_BASE_URL` para apontar para a API (emulador: `http://10.0.2.2:8080/api/v1`).

---

## Migrations (se usar volume novo)

```powershell
Get-Content backend\migrations\001_initial.sql -Raw | docker exec -i egranja-postgres psql -U egranja -d egranja
Get-Content backend\migrations\002_seed.sql -Raw | docker exec -i egranja-postgres psql -U egranja -d egranja
Get-Content backend\migrations\003_granja_colaboradores.sql -Raw | docker exec -i egranja-postgres psql -U egranja -d egranja
```

---

## App Mobile (Expo) no emulador Android

Requisito: **Node.js 20+** no PATH (instale em https://nodejs.org se precisar).

No emulador Android, use a URL da API no seu PC:
- **Android emulador**: `http://10.0.2.2:8080/api/v1`

**Windows (PowerShell):**

```powershell
cd mobile
$env:EXPO_PUBLIC_API_BASE_URL = "http://10.0.2.2:8080/api/v1"
npx expo start --android
```

Defina `EXPO_PUBLIC_API_BASE_URL` antes de rodar `npx expo start`.

---

## Comandos úteis (Docker)

| Ação | Comando |
|------|--------|
| Parar todos os containers eGranja | `docker compose -f docker/docker-compose.yml down` |
| Subir containers | `docker compose -f docker/docker-compose.yml up -d` |
| Logs do backend | `docker logs egranja-backend -f` |
| Logs do web | `docker logs egranja-web -f` |
| Logs do Postgres | `docker logs egranja-postgres -f` |

---

## Se Node/npm não for encontrado (só para o mobile)

Se no terminal aparecer que `npm` ou `node` não são reconhecidos:

1. Instale o [Node.js LTS](https://nodejs.org/) (inclui npm) e reinicie o terminal.
2. Ou use o terminal integrado do Cursor/VS Code (ele pode carregar outro PATH).
3. Se usar **nvm-windows**, abra um novo terminal após `nvm use` para que `npm` esteja no PATH.

Depois disso, rode os comandos da seção **App Mobile** acima.
