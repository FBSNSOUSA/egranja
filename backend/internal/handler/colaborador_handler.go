package handler

import (
	"errors"
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// ColaboradorHandler gerencia os endpoints de colaboradores de granjas.
type ColaboradorHandler struct {
	colaboradorRepo *repository.GranjaColaboradorRepository
	granjaRepo      *repository.GranjaRepository
	usuarioRepo     *repository.UsuarioRepository
	validate        *validator.Validate
	logger          *zap.Logger
}

// NewColaboradorHandler cria uma nova instancia de ColaboradorHandler.
func NewColaboradorHandler(
	colaboradorRepo *repository.GranjaColaboradorRepository,
	granjaRepo *repository.GranjaRepository,
	usuarioRepo *repository.UsuarioRepository,
	logger *zap.Logger,
) *ColaboradorHandler {
	return &ColaboradorHandler{
		colaboradorRepo: colaboradorRepo,
		granjaRepo:      granjaRepo,
		usuarioRepo:     usuarioRepo,
		validate:        validator.New(),
		logger:          logger,
	}
}

// List godoc
// @Summary      Listar colaboradores
// @Description  Lista todos os colaboradores de uma granja
// @Tags         colaboradores
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID da granja"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.ColaboradorResponse}
// @Router       /granjas/{id}/colaboradores [get]
func (h *ColaboradorHandler) List(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	granjaID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID invalido.")
		return
	}

	// Verificar se a granja existe e o usuario e proprietario
	granja, err := h.granjaRepo.FindByID(granjaID)
	if err != nil {
		if errors.Is(err, repository.ErrGranjaNotFound) {
			dto.RespondNotFound(c, "Granja nao encontrada.")
			return
		}
		h.logger.Error("Erro ao buscar granja", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar granja.")
		return
	}

	if granja.UsuarioID != userID {
		dto.RespondForbidden(c, "Apenas o proprietario pode gerenciar colaboradores.")
		return
	}

	colabs, err := h.colaboradorRepo.FindByGranja(granjaID)
	if err != nil {
		h.logger.Error("Erro ao listar colaboradores", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar colaboradores.")
		return
	}

	var response []dto.ColaboradorResponse
	for _, c := range colabs {
		response = append(response, dto.ColaboradorResponse{
			ID:          c.ID,
			GranjaID:    c.GranjaID,
			UsuarioID:   c.UsuarioID,
			UsuarioNome: c.Usuario.Nome,
			Permissao:   c.Permissao,
			CreatedAt:   c.CreatedAt,
		})
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// Add godoc
// @Summary      Adicionar colaborador
// @Description  Adiciona um colaborador a uma granja (somente proprietario)
// @Tags         colaboradores
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID da granja"
// @Param        body body dto.AddColaboradorRequest true "Dados do colaborador"
// @Success      201 {object} dto.SuccessResponse{data=dto.ColaboradorResponse}
// @Router       /granjas/{id}/colaboradores [post]
func (h *ColaboradorHandler) Add(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	granjaID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID invalido.")
		return
	}

	// Verificar se a granja existe e o usuario e proprietario
	granja, err := h.granjaRepo.FindByID(granjaID)
	if err != nil {
		if errors.Is(err, repository.ErrGranjaNotFound) {
			dto.RespondNotFound(c, "Granja nao encontrada.")
			return
		}
		h.logger.Error("Erro ao buscar granja", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar granja.")
		return
	}

	if granja.UsuarioID != userID {
		dto.RespondForbidden(c, "Apenas o proprietario pode adicionar colaboradores.")
		return
	}

	var req dto.AddColaboradorRequest
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

	// Nao pode adicionar a si mesmo
	if req.UsuarioID == userID {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Voce ja e proprietario desta granja.")
		return
	}

	// Verificar se o usuario convidado existe
	convidado, err := h.usuarioRepo.FindByID(req.UsuarioID)
	if err != nil {
		dto.RespondNotFound(c, "Usuario convidado nao encontrado.")
		return
	}

	colab := model.GranjaColaborador{
		GranjaID:     granjaID,
		UsuarioID:    req.UsuarioID,
		Permissao:    req.Permissao,
		ConvidadoPor: userID,
	}

	if err := h.colaboradorRepo.Create(&colab); err != nil {
		if errors.Is(err, repository.ErrColaboradorDuplicado) {
			dto.RespondError(c, http.StatusConflict, "CONFLICT", "Este usuario ja e colaborador desta granja.")
			return
		}
		h.logger.Error("Erro ao adicionar colaborador", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao adicionar colaborador.")
		return
	}

	resp := dto.ColaboradorResponse{
		ID:          colab.ID,
		GranjaID:    colab.GranjaID,
		UsuarioID:   colab.UsuarioID,
		UsuarioNome: convidado.Nome,
		Permissao:   colab.Permissao,
		CreatedAt:   colab.CreatedAt,
	}

	dto.RespondSuccess(c, http.StatusCreated, resp)
}

// Remove godoc
// @Summary      Remover colaborador
// @Description  Remove um colaborador de uma granja (somente proprietario)
// @Tags         colaboradores
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID da granja"
// @Param        uid path string true "ID do usuario colaborador"
// @Success      200 {object} dto.SuccessResponse
// @Router       /granjas/{id}/colaboradores/{uid} [delete]
func (h *ColaboradorHandler) Remove(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	granjaID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID da granja invalido.")
		return
	}

	colaboradorUID, err := uuid.Parse(c.Param("uid"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID do colaborador invalido.")
		return
	}

	// Verificar se a granja existe e o usuario e proprietario
	granja, err := h.granjaRepo.FindByID(granjaID)
	if err != nil {
		if errors.Is(err, repository.ErrGranjaNotFound) {
			dto.RespondNotFound(c, "Granja nao encontrada.")
			return
		}
		h.logger.Error("Erro ao buscar granja", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar granja.")
		return
	}

	if granja.UsuarioID != userID {
		dto.RespondForbidden(c, "Apenas o proprietario pode remover colaboradores.")
		return
	}

	if err := h.colaboradorRepo.Delete(granjaID, colaboradorUID); err != nil {
		if errors.Is(err, repository.ErrColaboradorNotFound) {
			dto.RespondNotFound(c, "Colaborador nao encontrado nesta granja.")
			return
		}
		h.logger.Error("Erro ao remover colaborador", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao remover colaborador.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, gin.H{"message": "Colaborador removido com sucesso."})
}
