package handler

import (
	"errors"
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.uber.org/zap"
)

// AuthHandler gerencia os endpoints de autenticacao.
type AuthHandler struct {
	authService *service.AuthService
	validate    *validator.Validate
	logger      *zap.Logger
}

// NewAuthHandler cria uma nova instancia de AuthHandler.
func NewAuthHandler(authService *service.AuthService, logger *zap.Logger) *AuthHandler {
	return &AuthHandler{
		authService: authService,
		validate:    validator.New(),
		logger:      logger,
	}
}

// Login godoc
// @Summary      Login de usuario
// @Description  Autentica um usuario e retorna tokens JWT (access + refresh)
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body body dto.LoginRequest true "Credenciais"
// @Success      200 {object} dto.SuccessResponse{data=dto.LoginResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      401 {object} dto.ErrorResponse
// @Failure      422 {object} dto.ErrorResponse
// @Router       /auth/login [post]
func (h *AuthHandler) Login(c *gin.Context) {
	var req dto.LoginRequest

	// Bind JSON
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	// Validar campos
	if err := h.validate.Struct(req); err != nil {
		var validationErrors validator.ValidationErrors
		if errors.As(err, &validationErrors) {
			details := make([]dto.ErrorDetail, 0, len(validationErrors))
			for _, fe := range validationErrors {
				details = append(details, dto.ErrorDetail{
					Field:   fe.Field(),
					Message: translateValidationError(fe),
				})
			}
			dto.RespondValidationError(c, details)
			return
		}
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Erro de validacao.")
		return
	}

	// Autenticar
	result, err := h.authService.Login(req)
	if err != nil {
		if errors.Is(err, service.ErrInvalidCredentials) {
			dto.RespondError(c, http.StatusUnauthorized, "INVALID_CREDENTIALS", "Usuario ou senha incorretos.")
			return
		}
		h.logger.Error("Erro no login", zap.Error(err))
		dto.RespondInternalError(c, "Erro interno ao processar login.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, result)
}

// Refresh godoc
// @Summary      Renovar token
// @Description  Renova o access token usando um refresh token valido
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body body dto.RefreshRequest true "Refresh token"
// @Success      200 {object} dto.SuccessResponse{data=dto.RefreshResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      401 {object} dto.ErrorResponse
// @Router       /auth/refresh [post]
func (h *AuthHandler) Refresh(c *gin.Context) {
	var req dto.RefreshRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	if err := h.validate.Struct(req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "VALIDATION_ERROR", "Refresh token e obrigatorio.")
		return
	}

	result, err := h.authService.RefreshToken(req)
	if err != nil {
		if errors.Is(err, service.ErrInvalidRefreshToken) {
			dto.RespondError(c, http.StatusUnauthorized, "INVALID_REFRESH_TOKEN", "Refresh token invalido ou expirado. Faca login novamente.")
			return
		}
		h.logger.Error("Erro ao renovar token", zap.Error(err))
		dto.RespondInternalError(c, "Erro interno ao renovar token.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, result)
}

// translateValidationError converte erros de validacao em mensagens legiveis.
func translateValidationError(fe validator.FieldError) string {
	switch fe.Tag() {
	case "required":
		return fe.Field() + " e obrigatorio."
	case "min":
		return fe.Field() + " deve ter no minimo " + fe.Param() + " caracteres."
	case "max":
		return fe.Field() + " deve ter no maximo " + fe.Param() + " caracteres."
	case "gt":
		return fe.Field() + " deve ser maior que " + fe.Param() + "."
	case "gte":
		return fe.Field() + " deve ser maior ou igual a " + fe.Param() + "."
	case "oneof":
		return fe.Field() + " deve ser um dos valores: " + fe.Param() + "."
	case "email":
		return fe.Field() + " deve ser um email valido."
	default:
		return fe.Field() + " invalido."
	}
}
