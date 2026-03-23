package handler

import (
	"errors"
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
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

// Register godoc
// @Summary      Registro de usuario
// @Description  Cria um novo usuario (produtor ou tecnico) no sistema
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body body dto.RegisterRequest true "Dados de registro"
// @Success      201 {object} dto.SuccessResponse{data=dto.RegisterResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      409 {object} dto.ErrorResponse
// @Failure      422 {object} dto.ErrorResponse
// @Router       /auth/register [post]
func (h *AuthHandler) Register(c *gin.Context) {
	var req dto.RegisterRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

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

	result, err := h.authService.Register(req)
	if err != nil {
		if errors.Is(err, service.ErrEmailAlreadyExists) {
			dto.RespondError(c, http.StatusConflict, "EMAIL_EXISTS", "Este email ja esta cadastrado.")
			return
		}
		h.logger.Error("Erro no registro", zap.Error(err))
		dto.RespondInternalError(c, "Erro interno ao processar registro.")
		return
	}

	dto.RespondSuccess(c, http.StatusCreated, result)
}

// ForgotPassword godoc
// @Summary      Solicitar reset de senha
// @Description  Gera um token de reset de senha e envia por email (quando SMTP configurado)
// @Tags         auth
// @Accept       json
// @Produce      json
// @Param        body body dto.ForgotPasswordRequest true "Email do usuario"
// @Success      200 {object} dto.SuccessResponse{data=dto.ForgotPasswordResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Router       /auth/forgot-password [post]
func (h *AuthHandler) ForgotPassword(c *gin.Context) {
	var req dto.ForgotPasswordRequest

	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

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

	result, err := h.authService.ForgotPassword(req)
	if err != nil {
		h.logger.Error("Erro ao processar forgot password", zap.Error(err))
		dto.RespondInternalError(c, "Erro interno ao processar solicitacao.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, result)
}

// GetProfile godoc
// @Summary      Obter perfil do usuario
// @Description  Retorna os dados do perfil do usuario autenticado
// @Tags         auth
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SuccessResponse{data=dto.ProfileResponse}
// @Failure      401 {object} dto.ErrorResponse
// @Router       /auth/profile [get]
func (h *AuthHandler) GetProfile(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	result, err := h.authService.GetProfile(userID)
	if err != nil {
		if errors.Is(err, service.ErrUserNotFound) {
			dto.RespondNotFound(c, "Usuario nao encontrado.")
			return
		}
		h.logger.Error("Erro ao obter perfil", zap.Error(err))
		dto.RespondInternalError(c, "Erro interno ao obter perfil.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, result)
}

// UpdateProfile godoc
// @Summary      Atualizar perfil do usuario
// @Description  Atualiza nome, email, telefone e/ou foto do usuario autenticado
// @Tags         auth
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body body dto.UpdateProfileRequest true "Dados para atualizar"
// @Success      200 {object} dto.SuccessResponse{data=dto.ProfileResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      401 {object} dto.ErrorResponse
// @Router       /auth/profile [patch]
func (h *AuthHandler) UpdateProfile(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	var req dto.UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

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

	result, err := h.authService.UpdateProfile(userID, req)
	if err != nil {
		if errors.Is(err, service.ErrUserNotFound) {
			dto.RespondNotFound(c, "Usuario nao encontrado.")
			return
		}
		h.logger.Error("Erro ao atualizar perfil", zap.Error(err))
		dto.RespondInternalError(c, "Erro interno ao atualizar perfil.")
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
