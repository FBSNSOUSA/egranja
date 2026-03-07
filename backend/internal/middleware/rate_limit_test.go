package middleware

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"golang.org/x/time/rate"
)

func TestRateLimit_UnderLimit(t *testing.T) {
	gin.SetMode(gin.TestMode)

	// Limiter generoso: 100 req/s com burst de 100
	rl := NewRateLimiter(rate.Limit(100), 100)

	router := gin.New()
	router.Use(rl.Middleware())
	router.GET("/test", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	// Fazer 5 requisicoes - devem passar
	for i := 0; i < 5; i++ {
		req, _ := http.NewRequest("GET", "/test", nil)
		req.RemoteAddr = "192.168.1.1:12345"
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		assert.Equal(t, http.StatusOK, w.Code, "Requisicao %d deveria passar", i+1)
	}
}

func TestRateLimit_OverLimit(t *testing.T) {
	gin.SetMode(gin.TestMode)

	// Limiter restritivo: 1 req/s com burst de 1
	rl := NewRateLimiter(rate.Limit(1), 1)

	router := gin.New()
	router.Use(rl.Middleware())
	router.GET("/test", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	// Primeira requisicao deve passar
	req1, _ := http.NewRequest("GET", "/test", nil)
	req1.RemoteAddr = "10.0.0.1:12345"
	w1 := httptest.NewRecorder()
	router.ServeHTTP(w1, req1)
	assert.Equal(t, http.StatusOK, w1.Code)

	// Requisicoes subsequentes imediatas devem ser bloqueadas
	blocked := false
	for i := 0; i < 10; i++ {
		req, _ := http.NewRequest("GET", "/test", nil)
		req.RemoteAddr = "10.0.0.1:12345"
		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)
		if w.Code == http.StatusTooManyRequests {
			blocked = true
			assert.Contains(t, w.Body.String(), "RATE_LIMIT_EXCEEDED")
			break
		}
	}
	assert.True(t, blocked, "Deveria ter bloqueado alguma requisicao por rate limit")
}

func TestRateLimit_DifferentIPs(t *testing.T) {
	gin.SetMode(gin.TestMode)

	// Limiter restritivo
	rl := NewRateLimiter(rate.Limit(1), 1)

	router := gin.New()
	router.Use(rl.Middleware())
	router.GET("/test", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"ok": true})
	})

	// IP 1 - primeira requisicao deve passar
	req1, _ := http.NewRequest("GET", "/test", nil)
	req1.RemoteAddr = "192.168.1.1:12345"
	w1 := httptest.NewRecorder()
	router.ServeHTTP(w1, req1)
	assert.Equal(t, http.StatusOK, w1.Code)

	// IP 2 - tambem deve passar (limite separado)
	req2, _ := http.NewRequest("GET", "/test", nil)
	req2.RemoteAddr = "192.168.1.2:12345"
	w2 := httptest.NewRecorder()
	router.ServeHTTP(w2, req2)
	assert.Equal(t, http.StatusOK, w2.Code)
}

func TestLoginRateLimiter(t *testing.T) {
	rl := LoginRateLimiter()
	assert.NotNil(t, rl)
	assert.Equal(t, 60, rl.burst)
}

func TestGeneralRateLimiter(t *testing.T) {
	rl := GeneralRateLimiter()
	assert.NotNil(t, rl)
	assert.Equal(t, 200, rl.burst)
}
