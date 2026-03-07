package config

import (
	"os"
	"strconv"
	"time"

	"github.com/joho/godotenv"
	"go.uber.org/zap"
)

// Config armazena todas as configuracoes do backend eGranja.
type Config struct {
	// Servidor HTTP
	Port    string
	GinMode string

	// Banco de Dados
	DatabaseURL string

	// JWT
	JWTSecret       string
	JWTAccessExpiry time.Duration
	JWTRefreshExpiry time.Duration

	// Bcrypt
	BcryptCost int

	// Storage (MinIO/S3)
	StorageEndpoint  string
	StorageAccessKey string
	StorageSecretKey string
	StorageBucket    string
	StorageUseSSL    bool

	// Firebase
	FirebaseCredentialsFile string

	// Gemini (IA)
	GeminiAPIKey            string
	GeminiModel             string
	GeminiMaxCallsPerUserDay int

	// MQTT (IoT)
	MQTTBrokerURL   string
	MQTTUsername     string
	MQTTPassword    string
	MQTTTopicPrefix string

	// Previsao do Tempo
	WeatherProvider       string
	WeatherFallbackAPIKey string
	WeatherCronSchedule   string
}

// Load carrega as configuracoes a partir de variaveis de ambiente.
// Tenta carregar .env se existir (sem erro se nao encontrar).
func Load() *Config {
	// Carrega .env silenciosamente
	_ = godotenv.Load()

	cfg := &Config{
		Port:    getEnv("PORT", "8080"),
		GinMode: getEnv("GIN_MODE", "debug"),

		DatabaseURL: getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/egranja?sslmode=disable"),

		JWTSecret:        getEnv("JWT_SECRET", "chave-secreta-desenvolvimento"),
		JWTAccessExpiry:  parseDuration("JWT_ACCESS_EXPIRY", 24*time.Hour),
		JWTRefreshExpiry: parseDuration("JWT_REFRESH_EXPIRY", 720*time.Hour),

		BcryptCost: getEnvInt("BCRYPT_COST", 12),

		StorageEndpoint:  getEnv("STORAGE_ENDPOINT", "localhost:9000"),
		StorageAccessKey: getEnv("STORAGE_ACCESS_KEY", "minioadmin"),
		StorageSecretKey: getEnv("STORAGE_SECRET_KEY", "minioadmin"),
		StorageBucket:    getEnv("STORAGE_BUCKET", "egranja-media"),
		StorageUseSSL:    getEnvBool("STORAGE_USE_SSL", false),

		FirebaseCredentialsFile: getEnv("FIREBASE_CREDENTIALS_FILE", ""),

		GeminiAPIKey:             getEnv("GEMINI_API_KEY", ""),
		GeminiModel:              getEnv("GEMINI_MODEL", "gemini-2.0-flash"),
		GeminiMaxCallsPerUserDay: getEnvInt("GEMINI_MAX_CALLS_PER_USER_DAY", 100),

		MQTTBrokerURL:   getEnv("MQTT_BROKER_URL", "tcp://localhost:1883"),
		MQTTUsername:     getEnv("MQTT_USERNAME", ""),
		MQTTPassword:    getEnv("MQTT_PASSWORD", ""),
		MQTTTopicPrefix: getEnv("MQTT_TOPIC_PREFIX", "egranja/"),

		WeatherProvider:       getEnv("WEATHER_PROVIDER", "open-meteo"),
		WeatherFallbackAPIKey: getEnv("WEATHER_FALLBACK_API_KEY", ""),
		WeatherCronSchedule:   getEnv("WEATHER_CRON_SCHEDULE", "0 6,18 * * *"),
	}

	return cfg
}

// Validate verifica campos obrigatorios em producao.
func (c *Config) Validate(logger *zap.Logger) {
	if c.JWTSecret == "chave-secreta-desenvolvimento" {
		logger.Warn("JWT_SECRET usando valor padrao de desenvolvimento. Defina um segredo seguro em producao.")
	}
	if c.DatabaseURL == "" {
		logger.Fatal("DATABASE_URL e obrigatorio")
	}
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}

func getEnvInt(key string, fallback int) int {
	if v := os.Getenv(key); v != "" {
		if i, err := strconv.Atoi(v); err == nil {
			return i
		}
	}
	return fallback
}

func getEnvBool(key string, fallback bool) bool {
	if v := os.Getenv(key); v != "" {
		if b, err := strconv.ParseBool(v); err == nil {
			return b
		}
	}
	return fallback
}

func parseDuration(key string, fallback time.Duration) time.Duration {
	if v := os.Getenv(key); v != "" {
		if d, err := time.ParseDuration(v); err == nil {
			return d
		}
	}
	return fallback
}
