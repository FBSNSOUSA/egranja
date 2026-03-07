package main

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/config"
	"github.com/FBSNSOUSA/egranja/backend/internal/handler"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	gormlogger "gorm.io/gorm/logger"
)

func main() {
	// ── Logger ──────────────────────────────────────────────────────────
	logger := setupLogger()
	defer func() {
		_ = logger.Sync()
	}()

	logger.Info("Iniciando eGranja Backend...")

	// ── Configuracao ────────────────────────────────────────────────────
	cfg := config.Load()
	cfg.Validate(logger)

	// ── Banco de Dados ──────────────────────────────────────────────────
	db, err := setupDatabase(cfg, logger)
	if err != nil {
		logger.Fatal("Falha ao conectar com o banco de dados", zap.Error(err))
	}
	logger.Info("Conexao com banco de dados estabelecida")

	// ── Repositories ────────────────────────────────────────────────────
	usuarioRepo := repository.NewUsuarioRepository(db)
	loteRepo := repository.NewLoteRepository(db)

	// ── Services ────────────────────────────────────────────────────────
	authService := service.NewAuthService(usuarioRepo, cfg, logger)
	_ = service.NewIndicadoresService(loteRepo, logger)

	// ── Handlers ────────────────────────────────────────────────────────
	authHandler := handler.NewAuthHandler(authService, logger)
	healthHandler := handler.NewHealthHandler(db)

	// ── Gin Router ──────────────────────────────────────────────────────
	gin.SetMode(cfg.GinMode)
	router := gin.New()

	// ── Middlewares Globais ──────────────────────────────────────────────
	router.Use(gin.Recovery())
	router.Use(requestLogger(logger))
	router.Use(middleware.CORSMiddleware())

	// ── Rate Limiters ───────────────────────────────────────────────────
	loginLimiter := middleware.LoginRateLimiter()
	generalLimiter := middleware.GeneralRateLimiter()

	// ── Rotas ───────────────────────────────────────────────────────────
	// Health check (sem autenticacao)
	router.GET("/health", healthHandler.Check)

	// API v1
	api := router.Group("/api/v1")
	api.Use(generalLimiter.Middleware())

	// Auth (sem autenticacao JWT, com rate limit especifico para login)
	auth := api.Group("/auth")
	{
		auth.POST("/login", loginLimiter.Middleware(), authHandler.Login)
		auth.POST("/refresh", authHandler.Refresh)
	}

	// Rotas protegidas (requerem JWT)
	protected := api.Group("")
	protected.Use(middleware.AuthMiddleware(cfg.JWTSecret, logger))
	{
		// Lotes
		// protected.GET("/lotes", loteHandler.List)
		// protected.POST("/lotes", loteHandler.Create)
		// protected.GET("/lotes/:id", loteHandler.Get)
		// protected.PATCH("/lotes/:id/finalizar", loteHandler.Finalizar)
		// protected.GET("/lotes/:id/indicadores", loteHandler.Indicadores)

		// Pesagens
		// protected.GET("/lotes/:id/pesagens", pesagemHandler.List)
		// protected.POST("/lotes/:id/pesagens", pesagemHandler.Create)

		// Mortalidade
		// protected.GET("/lotes/:id/mortalidades", mortalidadeHandler.List)
		// protected.POST("/lotes/:id/mortalidades", mortalidadeHandler.Create)

		// Racao
		// protected.GET("/lotes/:id/feed_receipts", feedHandler.ListReceipts)
		// protected.POST("/lotes/:id/feed_receipts", feedHandler.CreateReceipt)
		// protected.GET("/lotes/:id/feed_consumptions", feedHandler.ListConsumptions)
		// protected.POST("/lotes/:id/feed_consumptions", feedHandler.CreateConsumption)
		// protected.GET("/lotes/:id/racao/saldo", feedHandler.Saldo)

		// Agua
		// protected.GET("/lotes/:id/water_consumptions", waterHandler.List)
		// protected.POST("/lotes/:id/water_consumptions", waterHandler.Create)

		// Ambiencia
		// protected.GET("/lotes/:id/ambiencia", ambienciaHandler.List)
		// protected.POST("/lotes/:id/ambiencia", ambienciaHandler.Create)

		// Checklist
		// protected.GET("/lotes/:id/checklists", checklistHandler.List)
		// protected.POST("/lotes/:id/checklists", checklistHandler.Create)

		// Mensagens (Chat)
		// protected.GET("/lotes/:id/mensagens", mensagemHandler.List)
		// protected.POST("/lotes/:id/mensagens", mensagemHandler.Create)

		// WhatsApp
		// protected.GET("/lotes/:id/whatsapp_recipients", whatsappHandler.ListRecipients)
		// protected.POST("/lotes/:id/whatsapp_recipients", whatsappHandler.CreateRecipient)

		// Benchmarks
		// protected.GET("/benchmarks/:linhagem", benchmarkHandler.Get)

		// Granjas
		// protected.GET("/granjas", granjaHandler.List)
		// protected.POST("/granjas", granjaHandler.Create)
		// protected.GET("/granjas/:id", granjaHandler.Get)

		// Galpaos
		// protected.GET("/galpaos", galpaoHandler.List)

		// Tipos de racao
		// protected.GET("/tipos_racao", tipoRacaoHandler.List)

		// Sanidade
		// protected.GET("/lotes/:id/vacinacoes", vacinacaoHandler.List)
		// protected.POST("/lotes/:id/vacinacoes", vacinacaoHandler.Create)
		// protected.GET("/lotes/:id/medicamentos", medicamentoHandler.List)
		// protected.POST("/lotes/:id/medicamentos", medicamentoHandler.Create)

		// Visitantes
		// protected.GET("/granjas/:id/visitantes", visitanteHandler.List)
		// protected.POST("/granjas/:id/visitantes", visitanteHandler.Create)

		// Financeiro
		// protected.GET("/lotes/:id/custos", custoHandler.List)
		// protected.POST("/lotes/:id/custos", custoHandler.Create)
		// protected.POST("/lotes/:id/remuneracao", remuneracaoHandler.Create)

		// IoT
		// protected.POST("/iot/:galpao_id/dados", iotHandler.ReceberDados)
		// protected.GET("/iot/:galpao_id/status", iotHandler.Status)
		// protected.GET("/iot/:galpao_id/historico", iotHandler.Historico)

		// IA
		// protected.GET("/lotes/:id/ia/predicao", iaHandler.Predicao)
		// protected.POST("/ia/chat", iaHandler.Chat)

		// Clima
		// protected.GET("/granjas/:id/clima/atual", climaHandler.Atual)
		// protected.GET("/granjas/:id/clima/previsao", climaHandler.Previsao)

		// Rastreabilidade
		// protected.GET("/lotes/:id/rastreabilidade", rastreabilidadeHandler.Get)

		// Tecnico
		// tecnico := protected.Group("/tecnico")
		// tecnico.Use(middleware.RequireTipo("tecnico"))
		// tecnico.GET("/lotes", tecnicoHandler.ListLotes)
		// tecnico.GET("/alertas", tecnicoHandler.ListAlertas)

		// Sync
		// protected.POST("/sync", syncHandler.Sync)

		// Upload
		// protected.POST("/upload", uploadHandler.Upload)

		// Relatorios
		// protected.GET("/lotes/:id/relatorio/fechamento", relatorioHandler.Fechamento)
		// protected.GET("/lotes/:id/exportar/csv", relatorioHandler.ExportCSV)
	}

	// ── WebSocket ───────────────────────────────────────────────────────
	// router.GET("/api/v1/ws/lotes/:id", wsHandler.HandleConnection)
	// router.GET("/api/v1/iot/:galpao_id/tempo-real", wsIoTHandler.HandleConnection)

	// ── HTTP Server ─────────────────────────────────────────────────────
	srv := &http.Server{
		Addr:         ":" + cfg.Port,
		Handler:      router,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 30 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	// ── Graceful Shutdown ───────────────────────────────────────────────
	go func() {
		logger.Info("Servidor HTTP iniciado", zap.String("porta", cfg.Port))
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			logger.Fatal("Falha ao iniciar servidor", zap.Error(err))
		}
	}()

	// Aguardar sinal de parada (SIGINT ou SIGTERM)
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	sig := <-quit

	logger.Info("Sinal de parada recebido", zap.String("signal", sig.String()))

	// Contexto com timeout para shutdown
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		logger.Fatal("Erro ao parar servidor", zap.Error(err))
	}

	// Fechar conexao com banco
	sqlDB, err := db.DB()
	if err == nil {
		_ = sqlDB.Close()
	}

	logger.Info("Servidor eGranja encerrado com sucesso")
}

// setupLogger configura o logger zap.
func setupLogger() *zap.Logger {
	encoderConfig := zapcore.EncoderConfig{
		TimeKey:        "ts",
		LevelKey:       "level",
		NameKey:        "logger",
		CallerKey:      "caller",
		FunctionKey:    zapcore.OmitKey,
		MessageKey:     "msg",
		StacktraceKey:  "stacktrace",
		LineEnding:     zapcore.DefaultLineEnding,
		EncodeLevel:    zapcore.CapitalColorLevelEncoder,
		EncodeTime:     zapcore.ISO8601TimeEncoder,
		EncodeDuration: zapcore.SecondsDurationEncoder,
		EncodeCaller:   zapcore.ShortCallerEncoder,
	}

	logConfig := zap.Config{
		Level:            zap.NewAtomicLevelAt(zap.InfoLevel),
		Development:      true,
		Encoding:         "console",
		EncoderConfig:    encoderConfig,
		OutputPaths:      []string{"stdout"},
		ErrorOutputPaths: []string{"stderr"},
	}

	logger, err := logConfig.Build()
	if err != nil {
		panic(fmt.Sprintf("Falha ao criar logger: %v", err))
	}

	return logger
}

// setupDatabase configura a conexao com o PostgreSQL via GORM.
func setupDatabase(cfg *config.Config, logger *zap.Logger) (*gorm.DB, error) {
	gormConfig := &gorm.Config{
		Logger:                                   gormlogger.Default.LogMode(gormlogger.Warn),
		DisableForeignKeyConstraintWhenMigrating: true,
		PrepareStmt:                              true,
	}

	db, err := gorm.Open(postgres.Open(cfg.DatabaseURL), gormConfig)
	if err != nil {
		return nil, fmt.Errorf("erro ao abrir conexao com banco: %w", err)
	}

	// Configurar pool de conexoes
	sqlDB, err := db.DB()
	if err != nil {
		return nil, fmt.Errorf("erro ao obter *sql.DB: %w", err)
	}

	sqlDB.SetMaxOpenConns(25)
	sqlDB.SetMaxIdleConns(10)
	sqlDB.SetConnMaxLifetime(5 * time.Minute)
	sqlDB.SetConnMaxIdleTime(1 * time.Minute)

	// Testar conexao
	if err := sqlDB.Ping(); err != nil {
		return nil, fmt.Errorf("erro ao pingar banco de dados: %w", err)
	}

	return db, nil
}

// requestLogger cria um middleware de logging para requisicoes HTTP.
func requestLogger(logger *zap.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.Request.URL.Path
		query := c.Request.URL.RawQuery

		c.Next()

		latency := time.Since(start)
		status := c.Writer.Status()

		fields := []zap.Field{
			zap.Int("status", status),
			zap.String("method", c.Request.Method),
			zap.String("path", path),
			zap.String("ip", c.ClientIP()),
			zap.Duration("latency", latency),
		}

		if query != "" {
			fields = append(fields, zap.String("query", query))
		}

		if len(c.Errors) > 0 {
			fields = append(fields, zap.String("errors", c.Errors.ByType(gin.ErrorTypePrivate).String()))
		}

		switch {
		case status >= 500:
			logger.Error("Requisicao com erro do servidor", fields...)
		case status >= 400:
			logger.Warn("Requisicao com erro do cliente", fields...)
		default:
			logger.Info("Requisicao processada", fields...)
		}
	}
}
