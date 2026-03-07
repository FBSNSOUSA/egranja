package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

const (
	// ContextKeyUserID e a chave para o user_id no contexto do Gin.
	ContextKeyUserID = "user_id"
	// ContextKeyUserTipo e a chave para o tipo do usuario no contexto do Gin.
	ContextKeyUserTipo = "user_tipo"
)

// JWTClaims representa os claims do JWT do eGranja.
type JWTClaims struct {
	UserID uuid.UUID `json:"user_id"`
	Tipo   string    `json:"tipo"`
	jwt.RegisteredClaims
}

// AuthMiddleware retorna um middleware Gin que valida o token JWT
// no header Authorization (Bearer <token>).
func AuthMiddleware(jwtSecret string, logger *zap.Logger) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "UNAUTHORIZED",
					"message": "Token de autenticacao nao fornecido.",
				},
			})
			return
		}

		// Extrair o token do header "Bearer <token>"
		parts := strings.SplitN(authHeader, " ", 2)
		if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "UNAUTHORIZED",
					"message": "Formato de token invalido. Use: Bearer <token>.",
				},
			})
			return
		}

		tokenString := parts[1]

		// Parsear e validar o token
		claims := &JWTClaims{}
		token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
			// Validar o metodo de assinatura
			if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
				return nil, jwt.ErrSignatureInvalid
			}
			return []byte(jwtSecret), nil
		})

		if err != nil {
			logger.Debug("Falha ao validar JWT", zap.Error(err))
			code := "TOKEN_INVALID"
			message := "Token invalido."

			if err == jwt.ErrTokenExpired {
				code = "TOKEN_EXPIRED"
				message = "Token expirado. Renove usando o refresh token."
			}

			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    code,
					"message": message,
				},
			})
			return
		}

		if !token.Valid {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "TOKEN_INVALID",
					"message": "Token invalido.",
				},
			})
			return
		}

		// Setar o user_id e tipo no contexto do Gin
		c.Set(ContextKeyUserID, claims.UserID)
		c.Set(ContextKeyUserTipo, claims.Tipo)

		c.Next()
	}
}

// GetUserIDFromContext extrai o user_id do contexto do Gin.
func GetUserIDFromContext(c *gin.Context) (uuid.UUID, bool) {
	val, exists := c.Get(ContextKeyUserID)
	if !exists {
		return uuid.Nil, false
	}
	userID, ok := val.(uuid.UUID)
	return userID, ok
}

// GetUserTipoFromContext extrai o tipo do usuario do contexto do Gin.
func GetUserTipoFromContext(c *gin.Context) (string, bool) {
	val, exists := c.Get(ContextKeyUserTipo)
	if !exists {
		return "", false
	}
	tipo, ok := val.(string)
	return tipo, ok
}

// RequireTipo retorna um middleware que exige um tipo especifico de usuario.
func RequireTipo(tipos ...string) gin.HandlerFunc {
	return func(c *gin.Context) {
		tipo, ok := GetUserTipoFromContext(c)
		if !ok {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "UNAUTHORIZED",
					"message": "Usuario nao autenticado.",
				},
			})
			return
		}

		for _, t := range tipos {
			if tipo == t {
				c.Next()
				return
			}
		}

		c.AbortWithStatusJSON(http.StatusForbidden, gin.H{
			"success": false,
			"error": gin.H{
				"code":    "FORBIDDEN",
				"message": "Acesso nao permitido para seu tipo de usuario.",
			},
		})
	}
}
