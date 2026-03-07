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
	"go.uber.org/zap"
)

// GalpaoHandler gerencia os endpoints de galpoes.
type GalpaoHandler struct {
	galpaoRepo      *repository.GalpaoRepository
	granjaRepo      *repository.GranjaRepository
	colaboradorRepo *repository.GranjaColaboradorRepository
	validate        *validator.Validate
	logger          *zap.Logger
}

// NewGalpaoHandler cria uma nova instancia de GalpaoHandler.
func NewGalpaoHandler(
	galpaoRepo *repository.GalpaoRepository,
	granjaRepo *repository.GranjaRepository,
	colaboradorRepo *repository.GranjaColaboradorRepository,
	logger *zap.Logger,
) *GalpaoHandler {
	return &GalpaoHandler{
		galpaoRepo:      galpaoRepo,
		granjaRepo:      granjaRepo,
		colaboradorRepo: colaboradorRepo,
		validate:        validator.New(),
		logger:          logger,
	}
}

// List godoc
// @Summary      Listar galpoes
// @Description  Lista todos os galpoes acessiveis ao usuario autenticado
// @Tags         galpaos
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SuccessResponse{data=[]dto.GalpaoResponse}
// @Failure      401 {object} dto.ErrorResponse
// @Router       /galpaos [get]
func (h *GalpaoHandler) List(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	// Buscar IDs de granjas colaboradas para incluir galpoes
	granjaIDs, _ := h.colaboradorRepo.FindGranjaIDsAcessiveis(userID)

	galpaos, err := h.galpaoRepo.FindAcessiveis(userID, granjaIDs)
	if err != nil {
		h.logger.Error("Erro ao listar galpoes", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar galpoes.")
		return
	}

	var response []dto.GalpaoResponse
	for _, g := range galpaos {
		resp := dto.GalpaoResponse{
			ID:              g.ID,
			UsuarioID:       g.UsuarioID,
			GranjaID:        g.GranjaID,
			Nome:            g.Nome,
			Capacidade:      g.Capacidade,
			Latitude:        g.Latitude,
			Longitude:       g.Longitude,
			OrientacaoGraus: g.OrientacaoGraus,
			ComprimentoM:    g.ComprimentoM,
			LarguraM:        g.LarguraM,
			AreaM2:          g.AreaM2(),
			TipoVentilacao:  g.TipoVentilacao,
			LadoCortinas:    g.LadoCortinas,
			CreatedAt:       g.CreatedAt,
			UpdatedAt:       g.UpdatedAt,
		}
		response = append(response, resp)
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// Create godoc
// @Summary      Criar galpao
// @Description  Cria um novo galpao para o usuario autenticado
// @Tags         galpaos
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body body dto.CreateGalpaoRequest true "Dados do galpao"
// @Success      201 {object} dto.SuccessResponse{data=dto.GalpaoResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      422 {object} dto.ErrorResponse
// @Router       /galpaos [post]
func (h *GalpaoHandler) Create(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	var req dto.CreateGalpaoRequest
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

	// Verificar acesso a granja (se vinculado a uma)
	if req.GranjaID != nil {
		granja, err := h.granjaRepo.FindByID(*req.GranjaID)
		if err != nil {
			if errors.Is(err, repository.ErrGranjaNotFound) {
				dto.RespondNotFound(c, "Granja nao encontrada.")
				return
			}
			h.logger.Error("Erro ao buscar granja", zap.Error(err))
			dto.RespondInternalError(c, "Erro ao verificar granja.")
			return
		}
		// Precisa ser proprietario ou editor da granja
		if granja.UsuarioID != userID {
			perm, err := h.colaboradorRepo.UsuarioTemAcesso(granja.ID, userID)
			if err != nil || perm != "editor" {
				dto.RespondForbidden(c, "Voce precisa ser proprietario ou editor da granja para criar galpoes.")
				return
			}
		}
	}

	galpao := model.Galpao{
		UsuarioID:       userID,
		GranjaID:        req.GranjaID,
		Nome:            req.Nome,
		Capacidade:      req.Capacidade,
		Latitude:        req.Latitude,
		Longitude:       req.Longitude,
		OrientacaoGraus: req.OrientacaoGraus,
		ComprimentoM:    req.ComprimentoM,
		LarguraM:        req.LarguraM,
		TipoVentilacao:  req.TipoVentilacao,
		LadoCortinas:    req.LadoCortinas,
	}

	if err := h.galpaoRepo.Create(&galpao); err != nil {
		h.logger.Error("Erro ao criar galpao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao criar galpao.")
		return
	}

	resp := dto.GalpaoResponse{
		ID:              galpao.ID,
		UsuarioID:       galpao.UsuarioID,
		GranjaID:        galpao.GranjaID,
		Nome:            galpao.Nome,
		Capacidade:      galpao.Capacidade,
		Latitude:        galpao.Latitude,
		Longitude:       galpao.Longitude,
		OrientacaoGraus: galpao.OrientacaoGraus,
		ComprimentoM:    galpao.ComprimentoM,
		LarguraM:        galpao.LarguraM,
		AreaM2:          galpao.AreaM2(),
		TipoVentilacao:  galpao.TipoVentilacao,
		LadoCortinas:    galpao.LadoCortinas,
		CreatedAt:       galpao.CreatedAt,
		UpdatedAt:       galpao.UpdatedAt,
	}

	dto.RespondSuccess(c, http.StatusCreated, resp)
}
