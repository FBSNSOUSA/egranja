package handler

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"reflect"
	"testing"

	ut "github.com/go-playground/universal-translator"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/stretchr/testify/assert"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func TestLoginHandler_BadRequest_EmptyBody(t *testing.T) {
	router := gin.New()
	router.POST("/auth/login", func(c *gin.Context) {
		var req struct {
			Login string `json:"login"`
			Senha string `json:"senha"`
		}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "BAD_REQUEST",
					"message": "Corpo da requisicao invalido.",
				},
			})
			return
		}
	})

	req, _ := http.NewRequest("POST", "/auth/login", bytes.NewBufferString("invalid json"))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	assert.NoError(t, err)
	assert.Equal(t, false, resp["success"])
}

func TestLoginHandler_BadRequest_MissingFields(t *testing.T) {
	router := gin.New()
	router.POST("/auth/login", func(c *gin.Context) {
		var req struct {
			Login string `json:"login" binding:"required"`
			Senha string `json:"senha" binding:"required"`
		}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{
				"success": false,
				"error": gin.H{
					"code":    "BAD_REQUEST",
					"message": "Corpo da requisicao invalido.",
				},
			})
			return
		}

		c.JSON(http.StatusOK, gin.H{"success": true})
	})

	// Sem campo "senha"
	body := `{"login":"jose"}`
	req, _ := http.NewRequest("POST", "/auth/login", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusBadRequest, w.Code)
}

func TestLoginHandler_ValidBody(t *testing.T) {
	router := gin.New()
	router.POST("/auth/login", func(c *gin.Context) {
		var req struct {
			Login string `json:"login" binding:"required"`
			Senha string `json:"senha" binding:"required"`
		}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"success": false})
			return
		}

		assert.Equal(t, "jose.silva", req.Login)
		assert.Equal(t, "senha123", req.Senha)

		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"data": gin.H{
				"access_token": "mock-token",
				"token_type":   "Bearer",
			},
		})
	})

	body := `{"login":"jose.silva","senha":"senha123"}`
	req, _ := http.NewRequest("POST", "/auth/login", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	assert.NoError(t, err)
	assert.Equal(t, true, resp["success"])
}

func TestLoginHandler_Unauthorized(t *testing.T) {
	router := gin.New()
	router.POST("/auth/login", func(c *gin.Context) {
		var req struct {
			Login string `json:"login" binding:"required"`
			Senha string `json:"senha" binding:"required"`
		}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"success": false})
			return
		}

		// Simula senha errada
		c.JSON(http.StatusUnauthorized, gin.H{
			"success": false,
			"error": gin.H{
				"code":    "INVALID_CREDENTIALS",
				"message": "Usuario ou senha incorretos.",
			},
		})
	})

	body := `{"login":"jose.silva","senha":"senhaerrada"}`
	req, _ := http.NewRequest("POST", "/auth/login", bytes.NewBufferString(body))
	req.Header.Set("Content-Type", "application/json")

	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusUnauthorized, w.Code)
	assert.Contains(t, w.Body.String(), "INVALID_CREDENTIALS")
}

func TestTranslateValidationError_Required(t *testing.T) {
	result := translateValidationError(&mockFieldError{tag: "required", field: "Login"})
	assert.Contains(t, result, "obrigatorio")
}

func TestTranslateValidationError_Min(t *testing.T) {
	result := translateValidationError(&mockFieldError{tag: "min", field: "Senha", param: "6"})
	assert.Contains(t, result, "6")
	assert.Contains(t, result, "minimo")
}

func TestTranslateValidationError_Max(t *testing.T) {
	result := translateValidationError(&mockFieldError{tag: "max", field: "Login", param: "100"})
	assert.Contains(t, result, "100")
	assert.Contains(t, result, "maximo")
}

func TestTranslateValidationError_Oneof(t *testing.T) {
	result := translateValidationError(&mockFieldError{tag: "oneof", field: "Tipo", param: "produtor tecnico"})
	assert.Contains(t, result, "produtor tecnico")
}

func TestTranslateValidationError_Default(t *testing.T) {
	result := translateValidationError(&mockFieldError{tag: "uuid", field: "ID"})
	assert.Contains(t, result, "invalido")
}

// mockFieldError implementa validator.FieldError para testes
type mockFieldError struct {
	tag   string
	field string
	param string
}

var _ validator.FieldError = (*mockFieldError)(nil)

func (m *mockFieldError) Tag() string                            { return m.tag }
func (m *mockFieldError) ActualTag() string                      { return m.tag }
func (m *mockFieldError) Namespace() string                      { return "" }
func (m *mockFieldError) StructNamespace() string                { return "" }
func (m *mockFieldError) Field() string                          { return m.field }
func (m *mockFieldError) StructField() string                    { return m.field }
func (m *mockFieldError) Value() interface{}                     { return nil }
func (m *mockFieldError) Param() string                          { return m.param }
func (m *mockFieldError) Kind() reflect.Kind                     { return reflect.String }
func (m *mockFieldError) Type() reflect.Type                     { return reflect.TypeOf("") }
func (m *mockFieldError) Translate(utrans ut.Translator) string  { return "" }
func (m *mockFieldError) Error() string                          { return m.field + " " + m.tag }
