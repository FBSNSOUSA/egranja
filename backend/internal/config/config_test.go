package config

import (
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
)

func TestLoadConfig_Defaults(t *testing.T) {
	// Limpar variaveis de ambiente que poderiam interferir
	envVars := []string{
		"PORT", "GIN_MODE", "DATABASE_URL", "JWT_SECRET",
		"JWT_ACCESS_EXPIRY", "JWT_REFRESH_EXPIRY", "BCRYPT_COST",
		"STORAGE_ENDPOINT", "STORAGE_ACCESS_KEY", "STORAGE_SECRET_KEY",
		"STORAGE_BUCKET", "STORAGE_USE_SSL", "GEMINI_API_KEY",
		"GEMINI_MODEL", "GEMINI_MAX_CALLS_PER_USER_DAY",
		"MQTT_BROKER_URL", "MQTT_TOPIC_PREFIX",
		"WEATHER_PROVIDER", "WEATHER_CRON_SCHEDULE",
	}
	origValues := make(map[string]string)
	for _, key := range envVars {
		origValues[key] = os.Getenv(key)
		os.Unsetenv(key)
	}
	defer func() {
		for _, key := range envVars {
			if v, ok := origValues[key]; ok && v != "" {
				os.Setenv(key, v)
			}
		}
	}()

	cfg := Load()

	assert.Equal(t, "8080", cfg.Port)
	assert.Equal(t, "debug", cfg.GinMode)
	assert.Equal(t, "postgres://postgres:postgres@localhost:5432/egranja?sslmode=disable", cfg.DatabaseURL)
	assert.Equal(t, "chave-secreta-desenvolvimento", cfg.JWTSecret)
	assert.Equal(t, 24*time.Hour, cfg.JWTAccessExpiry)
	assert.Equal(t, 720*time.Hour, cfg.JWTRefreshExpiry)
	assert.Equal(t, 12, cfg.BcryptCost)
	assert.Equal(t, "localhost:9000", cfg.StorageEndpoint)
	assert.Equal(t, "minioadmin", cfg.StorageAccessKey)
	assert.Equal(t, "minioadmin", cfg.StorageSecretKey)
	assert.Equal(t, "egranja-media", cfg.StorageBucket)
	assert.False(t, cfg.StorageUseSSL)
	assert.Equal(t, "gemini-2.0-flash", cfg.GeminiModel)
	assert.Equal(t, 100, cfg.GeminiMaxCallsPerUserDay)
	assert.Equal(t, "tcp://localhost:1883", cfg.MQTTBrokerURL)
	assert.Equal(t, "egranja/", cfg.MQTTTopicPrefix)
	assert.Equal(t, "open-meteo", cfg.WeatherProvider)
	assert.Equal(t, "0 6,18 * * *", cfg.WeatherCronSchedule)
}

func TestLoadConfig_FromEnv(t *testing.T) {
	// Configurar variaveis de ambiente customizadas
	os.Setenv("PORT", "3000")
	os.Setenv("GIN_MODE", "release")
	os.Setenv("JWT_SECRET", "meu-segredo-producao")
	os.Setenv("JWT_ACCESS_EXPIRY", "1h")
	os.Setenv("JWT_REFRESH_EXPIRY", "168h")
	os.Setenv("BCRYPT_COST", "14")
	os.Setenv("STORAGE_USE_SSL", "true")
	os.Setenv("GEMINI_MAX_CALLS_PER_USER_DAY", "50")

	defer func() {
		os.Unsetenv("PORT")
		os.Unsetenv("GIN_MODE")
		os.Unsetenv("JWT_SECRET")
		os.Unsetenv("JWT_ACCESS_EXPIRY")
		os.Unsetenv("JWT_REFRESH_EXPIRY")
		os.Unsetenv("BCRYPT_COST")
		os.Unsetenv("STORAGE_USE_SSL")
		os.Unsetenv("GEMINI_MAX_CALLS_PER_USER_DAY")
	}()

	cfg := Load()

	assert.Equal(t, "3000", cfg.Port)
	assert.Equal(t, "release", cfg.GinMode)
	assert.Equal(t, "meu-segredo-producao", cfg.JWTSecret)
	assert.Equal(t, 1*time.Hour, cfg.JWTAccessExpiry)
	assert.Equal(t, 168*time.Hour, cfg.JWTRefreshExpiry)
	assert.Equal(t, 14, cfg.BcryptCost)
	assert.True(t, cfg.StorageUseSSL)
	assert.Equal(t, 50, cfg.GeminiMaxCallsPerUserDay)
}

func TestGetEnvInt_InvalidValue(t *testing.T) {
	os.Setenv("TEST_INT", "abc")
	defer os.Unsetenv("TEST_INT")

	result := getEnvInt("TEST_INT", 42)
	assert.Equal(t, 42, result)
}

func TestGetEnvBool_InvalidValue(t *testing.T) {
	os.Setenv("TEST_BOOL", "nao")
	defer os.Unsetenv("TEST_BOOL")

	result := getEnvBool("TEST_BOOL", true)
	assert.True(t, result)
}

func TestParseDuration_InvalidValue(t *testing.T) {
	os.Setenv("TEST_DUR", "invalido")
	defer os.Unsetenv("TEST_DUR")

	result := parseDuration("TEST_DUR", 5*time.Minute)
	assert.Equal(t, 5*time.Minute, result)
}
