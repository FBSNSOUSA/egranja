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

// GranjaHandler gerencia os endpoints de granjas.
type GranjaHandler struct {
	granjaRepo *repository.GranjaRepository
	loteRepo   *repository.LoteRepository
	validate   *validator.Validate
	logger     *zap.Logger
}

// NewGranjaHandler cria uma nova instancia de GranjaHandler.
func NewGranjaHandler(granjaRepo *repository.GranjaRepository, loteRepo *repository.LoteRepository, logger *zap.Logger) *GranjaHandler {
	return &GranjaHandler{
		granjaRepo: granjaRepo,
		loteRepo:   loteRepo,
		validate:   validator.New(),
		logger:     logger,
	}
}

// List godoc
// @Summary      Listar granjas
// @Description  Lista todas as granjas do usuario autenticado
// @Tags         granjas
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SuccessResponse{data=[]dto.GranjaResponse}
// @Failure      401 {object} dto.ErrorResponse
// @Router       /granjas [get]
func (h *GranjaHandler) List(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	granjas, err := h.granjaRepo.FindByUsuario(userID)
	if err != nil {
		h.logger.Error("Erro ao listar granjas", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar granjas.")
		return
	}

	var response []dto.GranjaResponse
	for _, g := range granjas {
		resp := dto.GranjaResponse{
			ID:           g.ID,
			UsuarioID:    g.UsuarioID,
			Nome:         g.Nome,
			Endereco:     g.Endereco,
			Cidade:       g.Cidade,
			Estado:       g.Estado,
			Latitude:     g.Latitude,
			Longitude:    g.Longitude,
			TotalGalpaos: len(g.Galpaos),
			CreatedAt:    g.CreatedAt,
			UpdatedAt:    g.UpdatedAt,
		}
		// Contar lotes ativos
		lotesAtivos, _ := h.granjaRepo.CountLotesAtivos(g.ID)
		resp.TotalLotesAtivos = int(lotesAtivos)
		response = append(response, resp)
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// Create godoc
// @Summary      Criar granja
// @Description  Cria uma nova granja para o usuario autenticado
// @Tags         granjas
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body body dto.CreateGranjaRequest true "Dados da granja"
// @Success      201 {object} dto.SuccessResponse{data=dto.GranjaResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      422 {object} dto.ErrorResponse
// @Router       /granjas [post]
func (h *GranjaHandler) Create(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	var req dto.CreateGranjaRequest
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

	granja := model.Granja{
		UsuarioID: userID,
		Nome:      req.Nome,
		Latitude:  req.Latitude,
		Longitude: req.Longitude,
	}
	if req.Endereco != nil {
		granja.Endereco = *req.Endereco
	}
	if req.Cidade != nil {
		granja.Cidade = *req.Cidade
	}
	if req.Estado != nil {
		granja.Estado = *req.Estado
	}

	if err := h.granjaRepo.Create(&granja); err != nil {
		h.logger.Error("Erro ao criar granja", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao criar granja.")
		return
	}

	resp := dto.GranjaResponse{
		ID:        granja.ID,
		UsuarioID: granja.UsuarioID,
		Nome:      granja.Nome,
		Endereco:  granja.Endereco,
		Cidade:    granja.Cidade,
		Estado:    granja.Estado,
		Latitude:  granja.Latitude,
		Longitude: granja.Longitude,
		CreatedAt: granja.CreatedAt,
		UpdatedAt: granja.UpdatedAt,
	}

	dto.RespondSuccess(c, http.StatusCreated, resp)
}

// Get godoc
// @Summary      Detalhes da granja
// @Description  Retorna os detalhes de uma granja com seus galpoes
// @Tags         granjas
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID da granja"
// @Success      200 {object} dto.SuccessResponse{data=dto.GranjaResponse}
// @Failure      404 {object} dto.ErrorResponse
// @Router       /granjas/{id} [get]
func (h *GranjaHandler) Get(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID invalido.")
		return
	}

	granja, err := h.granjaRepo.FindByID(id)
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
		dto.RespondForbidden(c, "Voce nao tem acesso a esta granja.")
		return
	}

	lotesAtivos, _ := h.granjaRepo.CountLotesAtivos(granja.ID)

	resp := dto.GranjaResponse{
		ID:               granja.ID,
		UsuarioID:        granja.UsuarioID,
		Nome:             granja.Nome,
		Endereco:         granja.Endereco,
		Cidade:           granja.Cidade,
		Estado:           granja.Estado,
		Latitude:         granja.Latitude,
		Longitude:        granja.Longitude,
		TotalGalpaos:     len(granja.Galpaos),
		TotalLotesAtivos: int(lotesAtivos),
		CreatedAt:        granja.CreatedAt,
		UpdatedAt:        granja.UpdatedAt,
	}

	dto.RespondSuccess(c, http.StatusOK, resp)
}

// Dashboard godoc
// @Summary      Dashboard consolidado
// @Description  Retorna o dashboard consolidado de todas as granjas do usuario
// @Tags         granjas
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SuccessResponse{data=dto.DashboardConsolidadoResponse}
// @Router       /granjas/dashboard [get]
func (h *GranjaHandler) Dashboard(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	granjas, err := h.granjaRepo.FindByUsuario(userID)
	if err != nil {
		h.logger.Error("Erro ao buscar granjas para dashboard", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao gerar dashboard.")
		return
	}

	dashboard := dto.DashboardConsolidadoResponse{}

	for _, g := range granjas {
		lotesAtivos, _ := h.granjaRepo.CountLotesAtivos(g.ID)

		resumo := dto.GranjaResumoDTO{
			ID:               g.ID,
			Nome:             g.Nome,
			TotalGalpaos:     len(g.Galpaos),
			TotalLotesAtivos: int(lotesAtivos),
		}

		dashboard.TotalGalpaos += len(g.Galpaos)
		dashboard.TotalLotesAtivos += int(lotesAtivos)
		dashboard.Granjas = append(dashboard.Granjas, resumo)
	}

	dashboard.TotalGranjas = len(granjas)

	dto.RespondSuccess(c, http.StatusOK, dashboard)
}

// Comparativo godoc
// @Summary      Comparativo entre granjas
// @Description  Retorna ranking de desempenho inter-granja
// @Tags         granjas
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SuccessResponse{data=dto.ComparativoGranjaResponse}
// @Router       /granjas/comparativo [get]
func (h *GranjaHandler) Comparativo(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	granjas, err := h.granjaRepo.FindByUsuario(userID)
	if err != nil {
		h.logger.Error("Erro ao buscar granjas para comparativo", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao gerar comparativo.")
		return
	}

	var comparativos []dto.GranjaComparativoDTO
	for _, g := range granjas {
		comp := dto.GranjaComparativoDTO{
			ID:   g.ID,
			Nome: g.Nome,
		}
		comparativos = append(comparativos, comp)
	}

	resp := dto.ComparativoGranjaResponse{
		Granjas: comparativos,
	}

	dto.RespondSuccess(c, http.StatusOK, resp)
}
