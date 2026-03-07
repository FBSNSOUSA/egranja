package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/zap"
)

const testSecret = "test-jwt-secret-middleware"

func init() {
	gin.SetMode(gin.TestMode)
}

func generateTestToken(userID uuid.UUID, tipo string, secret string, expiry time.Duration) string {
	now := time.Now()
	claims := JWTClaims{
		UserID: userID,
		Tipo:   tipo,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(expiry)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "egranja",
			Subject:   userID.String(),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenStr, _ := token.SignedString([]byte(secret))
	return tokenStr
}

func setupRouter(jwtSecret string) *gin.Engine {
	logger, _ := zap.NewDevelopment()
	r := gin.New()
	r.Use(AuthMiddleware(jwtSecret, logger))
	r.GET("/test", func(c *gin.Context) {
		userID, _ := GetUserIDFromContext(c)
		tipo, _ := GetUserTipoFromContext(c)
		c.JSON(http.StatusOK, gin.H{"user_id": userID.String(), "tipo": tipo})
	})
	return r
}

func TestJWTMiddleware_ValidToken(t *testing.T) {
	router := setupRouter(testSecret)
	userID := uuid.New()
	token := generateTestToken(userID, "produtor", testSecret, 24*time.Hour)

	req, _ := http.NewRequest("GET", "/test", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), userID.String())
	assert.Contains(t, w.Body.String(), "produtor")
}

func TestJWTMiddleware_NoToken(t *testing.T) {
	router := setupRouter(testSecret)

	req, _ := http.NewRequest("GET", "/test", nil)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
	assert.Contains(t, w.Body.String(), "UNAUTHORIZED")
}

func TestJWTMiddleware_InvalidToken(t *testing.T) {
	router := setupRouter(testSecret)

	req, _ := http.NewRequest("GET", "/test", nil)
	req.Header.Set("Authorization", "Bearer token-invalido-qualquer")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestJWTMiddleware_ExpiredToken(t *testing.T) {
	router := setupRouter(testSecret)
	userID := uuid.New()
	token := generateTestToken(userID, "produtor", testSecret, -1*time.Hour)

	req, _ := http.NewRequest("GET", "/test", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestJWTMiddleware_WrongSecret(t *testing.T) {
	router := setupRouter(testSecret)
	userID := uuid.New()
	token := generateTestToken(userID, "produtor", "outra-chave-secreta", 24*time.Hour)

	req, _ := http.NewRequest("GET", "/test", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestJWTMiddleware_InvalidFormat(t *testing.T) {
	router := setupRouter(testSecret)

	req, _ := http.NewRequest("GET", "/test", nil)
	req.Header.Set("Authorization", "Token abc123")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
}

func TestRequireTipo_TecnicoAccess(t *testing.T) {
	logger, _ := zap.NewDevelopment()

	router := gin.New()
	router.Use(AuthMiddleware(testSecret, logger))
	router.GET("/admin", RequireTipo("tecnico"), func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "acesso permitido"})
	})

	userID := uuid.New()
	token := generateTestToken(userID, "tecnico", testSecret, 24*time.Hour)

	req, _ := http.NewRequest("GET", "/admin", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
	assert.Contains(t, w.Body.String(), "acesso permitido")
}

func TestRequireTipo_ProdutorDenied(t *testing.T) {
	logger, _ := zap.NewDevelopment()

	router := gin.New()
	router.Use(AuthMiddleware(testSecret, logger))
	router.GET("/admin", RequireTipo("tecnico"), func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "acesso permitido"})
	})

	userID := uuid.New()
	token := generateTestToken(userID, "produtor", testSecret, 24*time.Hour)

	req, _ := http.NewRequest("GET", "/admin", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusForbidden, w.Code)
	assert.Contains(t, w.Body.String(), "FORBIDDEN")
}

func TestRequireTipo_MultipleTipos(t *testing.T) {
	logger, _ := zap.NewDevelopment()

	router := gin.New()
	router.Use(AuthMiddleware(testSecret, logger))
	router.GET("/shared", RequireTipo("tecnico", "produtor"), func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	userID := uuid.New()
	token := generateTestToken(userID, "produtor", testSecret, 24*time.Hour)

	req, _ := http.NewRequest("GET", "/shared", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)
}

func TestGetUserIDFromContext(t *testing.T) {
	userID := uuid.New()
	token := generateTestToken(userID, "produtor", testSecret, 24*time.Hour)

	var extractedID uuid.UUID
	var found bool

	logger, _ := zap.NewDevelopment()
	r := gin.New()
	r.Use(AuthMiddleware(testSecret, logger))
	r.GET("/extract", func(c *gin.Context) {
		extractedID, found = GetUserIDFromContext(c)
		c.Status(200)
	})

	req, _ := http.NewRequest("GET", "/extract", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	require.True(t, found)
	assert.Equal(t, userID, extractedID)
}

func TestGetUserTipoFromContext(t *testing.T) {
	logger, _ := zap.NewDevelopment()

	var extractedTipo string
	var found bool

	r := gin.New()
	r.Use(AuthMiddleware(testSecret, logger))
	r.GET("/tipo", func(c *gin.Context) {
		extractedTipo, found = GetUserTipoFromContext(c)
		c.Status(200)
	})

	userID := uuid.New()
	token := generateTestToken(userID, "tecnico", testSecret, 24*time.Hour)

	req, _ := http.NewRequest("GET", "/tipo", nil)
	req.Header.Set("Authorization", "Bearer "+token)

	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)

	require.True(t, found)
	assert.Equal(t, "tecnico", extractedTipo)
}
