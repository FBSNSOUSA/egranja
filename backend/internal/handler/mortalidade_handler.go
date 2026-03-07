package handler

import (
	"errors"
	"net/http"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.uber.org/zap"
)

// MortalidadeHandler gerencia os endpoints de mortalidade.
type MortalidadeHandler struct {
	mortalidadeRepo *repository.MortalidadeRepository
	loteRepo        *repository.LoteRepository
	blockchain      *service.BlockchainService
	validate        *validator.Validate
	logger          *zap.Logger
}

// NewMortalidadeHandler cria uma nova instancia de MortalidadeHandler.
func NewMortalidadeHandler(mortalidadeRepo *repository.MortalidadeRepository, loteRepo *repository.LoteRepository, blockchain *service.BlockchainService, logger *zap.Logger) *MortalidadeHandler {
	return &MortalidadeHandler{
		mortalidadeRepo: mortalidadeRepo,
		loteRepo:        loteRepo,
		blockchain:      blockchain,
		validate:        validator.New(),
		logger:          logger,
	}
}

// List godoc
// @Summary      Listar mortalidade
// @Description  Lista registros de mortalidade de um lote com paginacao e filtro por data
// @Tags         mortalidade
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        page query int false "Pagina" default(1)
// @Param        per_page query int false "Itens por pagina" default(20)
// @Param        data_inicio query string false "Data inicio (YYYY-MM-DD)"
// @Param        data_fim query string false "Data fim (YYYY-MM-DD)"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.MortalidadeResponse}
// @Router       /lotes/{id}/mortalidades [get]
func (h *MortalidadeHandler) List(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	page, perPage := dto.ParsePagination(c)

	var dataInicio, dataFim *time.Time
	if di := c.Query("data_inicio"); di != "" {
		t, err := time.Parse("2006-01-02", di)
		if err == nil {
			dataInicio = &t
		}
	}
	if df := c.Query("data_fim"); df != "" {
		t, err := time.Parse("2006-01-02", df)
		if err == nil {
			dataFim = &t
		}
	}

	mortalidades, total, err := h.mortalidadeRepo.FindByLote(lote.ID, dataInicio, dataFim, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar mortalidade", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar mortalidade.")
		return
	}

	var response []dto.MortalidadeResponse
	for _, m := range mortalidades {
		response = append(response, dto.MortalidadeResponse{
			ID:         m.ID,
			LoteID:     m.LoteID,
			Data:       m.Data,
			Quantidade: m.Quantidade,
			Causa:      m.Causa,
			Observacao: m.Observacao,
			FotoURL:    m.FotoURL,
			CreatedAt:  m.CreatedAt,
		})
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// Create godoc
// @Summary      Registrar mortalidade
// @Description  Cria um novo registro de mortalidade
// @Tags         mortalidade
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateMortalidadeRequest true "Dados de mortalidade"
// @Success      201 {object} dto.SuccessResponse{data=dto.MortalidadeResponse}
// @Router       /lotes/{id}/mortalidades [post]
func (h *MortalidadeHandler) Create(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateMortalidadeRequest
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

	data, err := time.Parse("2006-01-02", req.Data)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data invalida. Use formato YYYY-MM-DD.")
		return
	}

	mortalidade := model.Mortalidade{
		LoteID:     lote.ID,
		Data:       data,
		Quantidade: req.Quantidade,
		Causa:      req.Causa,
		Observacao: req.Observacao,
		FotoURL:    req.FotoURL,
	}
	if mortalidade.Causa == "" {
		mortalidade.Causa = "Indefinida"
	}

	if err := h.mortalidadeRepo.Create(&mortalidade); err != nil {
		h.logger.Error("Erro ao registrar mortalidade", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar mortalidade.")
		return
	}

	// Registrar na cadeia de rastreabilidade
	if h.blockchain != nil {
		_ = h.blockchain.RegistrarEvento(lote.ID, "mortalidade", map[string]interface{}{
			"data":       data.Format("2006-01-02"),
			"quantidade": req.Quantidade,
			"causa":      mortalidade.Causa,
		})
	}

	resp := dto.MortalidadeResponse{
		ID:         mortalidade.ID,
		LoteID:     mortalidade.LoteID,
		Data:       mortalidade.Data,
		Quantidade: mortalidade.Quantidade,
		Causa:      mortalidade.Causa,
		Observacao: mortalidade.Observacao,
		FotoURL:    mortalidade.FotoURL,
		CreatedAt:  mortalidade.CreatedAt,
	}

	dto.RespondSuccess(c, http.StatusCreated, resp)
}
