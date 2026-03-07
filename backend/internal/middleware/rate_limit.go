package middleware

import (
	"net/http"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
	"golang.org/x/time/rate"
)

// visitor armazena o limiter e o ultimo acesso de um visitante.
type visitor struct {
	limiter  *rate.Limiter
	lastSeen time.Time
}

// RateLimiter gerencia rate limiters por IP.
type RateLimiter struct {
	visitors map[string]*visitor
	mu       sync.RWMutex
	rate     rate.Limit
	burst    int
}

// NewRateLimiter cria um novo RateLimiter.
// r: requisicoes por segundo; burst: maximo de requisicoes em rajada.
func NewRateLimiter(r rate.Limit, burst int) *RateLimiter {
	rl := &RateLimiter{
		visitors: make(map[string]*visitor),
		rate:     r,
		burst:    burst,
	}

	// Limpar visitantes antigos a cada 3 minutos
	go rl.cleanupVisitors()

	return rl
}

// getVisitor retorna o rate limiter para um IP, criando um novo se necessario.
func (rl *RateLimiter) getVisitor(ip string) *rate.Limiter {
	rl.mu.Lock()
	defer rl.mu.Unlock()

	v, exists := rl.visitors[ip]
	if !exists {
		limiter := rate.NewLimiter(rl.rate, rl.burst)
		rl.visitors[ip] = &visitor{limiter: limiter, lastSeen: time.Now()}
		return limiter
	}

	v.lastSeen = time.Now()
	return v.limiter
}

// cleanupVisitors remove visitantes que nao acessam ha mais de 3 minutos.
func (rl *RateLimiter) cleanupVisitors() {
	for {
		time.Sleep(3 * time.Minute)

		rl.mu.Lock()
		for ip, v := range rl.visitors {
			if time.Since(v.lastSeen) > 3*time.Minute {
				delete(rl.visitors, ip)
			}
		}
		rl.mu.Unlock()
	}
}

// Middleware retorna o middleware Gin de rate limiting.
func (rl *RateLimiter) Middleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		ip := c.ClientIP()
		limiter := rl.getVisitor(ip)

		if !limiter.Allow() {
			c.AbortWithStatusJSON(http.StatusTooManyRequests, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "RATE_LIMIT_EXCEEDED",
					"message": "Muitas requisicoes. Tente novamente em alguns instantes.",
				},
			})
			return
		}

		c.Next()
	}
}

// LoginRateLimiter cria um rate limiter para o endpoint de login (60 req/min).
func LoginRateLimiter() *RateLimiter {
	return NewRateLimiter(rate.Every(time.Second), 60) // 60 req/min com burst de 60
}

// GeneralRateLimiter cria um rate limiter para os demais endpoints (200 req/min).
func GeneralRateLimiter() *RateLimiter {
	return NewRateLimiter(rate.Every(300*time.Millisecond), 200) // ~200 req/min com burst de 200
}
