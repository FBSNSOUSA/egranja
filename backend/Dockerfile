# =============================================================
# eGranja Backend - Multi-stage Docker Build
# =============================================================

# ---- Stage 1: Build ----
FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git ca-certificates tzdata

WORKDIR /app

# Cache de dependencias
COPY go.mod go.sum ./
RUN go mod download

# Build do binario
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags="-w -s" -o /app/bin/egranja ./cmd/server/main.go

# ---- Stage 2: Runtime ----
FROM alpine:3.19

RUN apk add --no-cache ca-certificates tzdata curl

# Timezone padrao Brasil
ENV TZ=America/Sao_Paulo

# Usuario nao-root
RUN addgroup -S egranja && adduser -S egranja -G egranja

WORKDIR /app

# Copiar binario do stage de build
COPY --from=builder /app/bin/egranja .
COPY --from=builder /app/migrations ./migrations

# Permissoes
RUN chown -R egranja:egranja /app
USER egranja

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:8080/api/v1/health || exit 1

ENTRYPOINT ["./egranja"]
