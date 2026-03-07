package service

import (
	"testing"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/config"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newTestConfig() *config.Config {
	return &config.Config{
		JWTSecret:        "test-secret-key-for-unit-tests",
		JWTAccessExpiry:  24 * time.Hour,
		JWTRefreshExpiry: 720 * time.Hour,
		BcryptCost:       4, // custo baixo para testes rapidos
	}
}

func TestGenerateAccessToken(t *testing.T) {
	cfg := newTestConfig()
	svc := &AuthService{cfg: cfg}

	userID := uuid.New()
	tipo := "produtor"

	tokenStr, err := svc.generateAccessToken(userID, tipo)
	require.NoError(t, err)
	assert.NotEmpty(t, tokenStr)

	// Parsear o token e verificar claims
	claims := &middleware.JWTClaims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(cfg.JWTSecret), nil
	})

	require.NoError(t, err)
	assert.True(t, token.Valid)
	assert.Equal(t, userID, claims.UserID)
	assert.Equal(t, "produtor", claims.Tipo)
	assert.Equal(t, "egranja", claims.Issuer)
	assert.Equal(t, userID.String(), claims.Subject)
	assert.NotNil(t, claims.ExpiresAt)
	assert.NotNil(t, claims.IssuedAt)
}

func TestGenerateRefreshToken(t *testing.T) {
	cfg := newTestConfig()
	svc := &AuthService{cfg: cfg}

	userID := uuid.New()
	tipo := "tecnico"

	tokenStr, err := svc.generateRefreshToken(userID, tipo)
	require.NoError(t, err)
	assert.NotEmpty(t, tokenStr)

	// Parsear o token e verificar claims
	claims := &middleware.JWTClaims{}
	token, err := jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(cfg.JWTSecret), nil
	})

	require.NoError(t, err)
	assert.True(t, token.Valid)
	assert.Equal(t, userID, claims.UserID)
	assert.Equal(t, "tecnico", claims.Tipo)
	assert.Equal(t, "egranja-refresh", claims.Issuer)
}

func TestGenerateTokens_DifferentTokens(t *testing.T) {
	cfg := newTestConfig()
	svc := &AuthService{cfg: cfg}

	userID := uuid.New()

	access, err := svc.generateAccessToken(userID, "produtor")
	require.NoError(t, err)

	refresh, err := svc.generateRefreshToken(userID, "produtor")
	require.NoError(t, err)

	assert.NotEqual(t, access, refresh, "Access e refresh tokens devem ser diferentes")
}

func TestGenerateAccessToken_Expiry(t *testing.T) {
	cfg := newTestConfig()
	cfg.JWTAccessExpiry = 1 * time.Hour
	svc := &AuthService{cfg: cfg}

	userID := uuid.New()
	tokenStr, err := svc.generateAccessToken(userID, "produtor")
	require.NoError(t, err)

	claims := &middleware.JWTClaims{}
	_, err = jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(cfg.JWTSecret), nil
	})
	require.NoError(t, err)

	// Verificar que expira em ~1h
	expiresAt := claims.ExpiresAt.Time
	issuedAt := claims.IssuedAt.Time
	diff := expiresAt.Sub(issuedAt)
	assert.InDelta(t, time.Hour.Seconds(), diff.Seconds(), 5, "Token deve expirar em ~1 hora")
}

func TestTokenValidation_WrongSecret(t *testing.T) {
	cfg := newTestConfig()
	svc := &AuthService{cfg: cfg}

	userID := uuid.New()
	tokenStr, err := svc.generateAccessToken(userID, "produtor")
	require.NoError(t, err)

	// Tentar parsear com chave errada
	claims := &middleware.JWTClaims{}
	_, err = jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte("chave-errada"), nil
	})

	assert.Error(t, err, "Token assinado com chave diferente deve falhar na validacao")
}

func TestTokenValidation_ExpiredToken(t *testing.T) {
	cfg := newTestConfig()
	cfg.JWTAccessExpiry = -1 * time.Hour // ja expirado
	svc := &AuthService{cfg: cfg}

	userID := uuid.New()
	tokenStr, err := svc.generateAccessToken(userID, "produtor")
	require.NoError(t, err)

	claims := &middleware.JWTClaims{}
	_, err = jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(cfg.JWTSecret), nil
	})

	assert.Error(t, err, "Token expirado deve falhar na validacao")
}

func TestTokenValidation_TipoProdutor(t *testing.T) {
	cfg := newTestConfig()
	svc := &AuthService{cfg: cfg}

	userID := uuid.New()
	tokenStr, err := svc.generateAccessToken(userID, "produtor")
	require.NoError(t, err)

	claims := &middleware.JWTClaims{}
	_, err = jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(cfg.JWTSecret), nil
	})

	require.NoError(t, err)
	assert.Equal(t, "produtor", claims.Tipo)
}

func TestTokenValidation_TipoTecnico(t *testing.T) {
	cfg := newTestConfig()
	svc := &AuthService{cfg: cfg}

	userID := uuid.New()
	tokenStr, err := svc.generateAccessToken(userID, "tecnico")
	require.NoError(t, err)

	claims := &middleware.JWTClaims{}
	_, err = jwt.ParseWithClaims(tokenStr, claims, func(token *jwt.Token) (interface{}, error) {
		return []byte(cfg.JWTSecret), nil
	})

	require.NoError(t, err)
	assert.Equal(t, "tecnico", claims.Tipo)
}
