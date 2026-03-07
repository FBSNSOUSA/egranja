package handler

import (
	"net/http"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// AmbienciaHandler gerencia os endpoints de registros ambientais.
type AmbienciaHandler struct {
	ambienciaRepo *repository.AmbienciaRepository
	loteRepo      *repository.LoteRepository
	logger        *zap.Logger
}

// NewAmbienciaHandler cria uma nova instancia de AmbienciaHandler.
func NewAmbienciaHandler(ambienciaRepo *repository.AmbienciaRepository, loteRepo *repository.LoteRepository, logger *zap.Logger) *AmbienciaHandler {
	return &AmbienciaHandler{
		ambienciaRepo: ambienciaRepo,
		loteRepo:      loteRepo,
		logger:        logger,
	}
}

// CreateAmbienciaRequest representa o payload de registro ambiental.
type CreateAmbienciaRequest struct {
	Data           string   `json:"data" binding:"required"`
	TemperaturaMin *float64 `json:"temperatura_min,omitempty"`
	TemperaturaMax *float64 `json:"temperatura_max,omitempty"`
	UmidadeMin     *float64 `json:"umidade_min,omitempty"`
	UmidadeMax     *float64 `json:"umidade_max,omitempty"`
	Origem         string   `json:"origem,omitempty"`
}

// List godoc
// @Summary      Listar registros ambientais
// @Description  Lista registros ambientais de um lote
// @Tags         ambiencia
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]model.RegistroAmbiental}
// @Router       /lotes/{id}/ambiencia [get]
func (h *AmbienciaHandler) List(c *gin.Context) {
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

	registros, total, err := h.ambienciaRepo.FindByLote(lote.ID, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar registros ambientais", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar registros ambientais.")
		return
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, registros, meta)
}

// Create godoc
// @Summary      Registrar ambiencia
// @Description  Registra temperatura e umidade
// @Tags         ambiencia
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body CreateAmbienciaRequest true "Dados ambientais"
// @Success      201 {object} dto.SuccessResponse{data=model.RegistroAmbiental}
// @Router       /lotes/{id}/ambiencia [post]
func (h *AmbienciaHandler) Create(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req CreateAmbienciaRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	data, err := time.Parse("2006-01-02", req.Data)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data invalida. Use formato YYYY-MM-DD.")
		return
	}

	registro := model.RegistroAmbiental{
		LoteID:         lote.ID,
		Data:           data,
		TemperaturaMin: req.TemperaturaMin,
		TemperaturaMax: req.TemperaturaMax,
		UmidadeMin:     req.UmidadeMin,
		UmidadeMax:     req.UmidadeMax,
		Origem:         req.Origem,
	}
	if registro.Origem == "" {
		registro.Origem = "manual"
	}

	if err := h.ambienciaRepo.Create(&registro); err != nil {
		h.logger.Error("Erro ao registrar ambiencia", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar ambiencia.")
		return
	}

	dto.RespondSuccess(c, http.StatusCreated, registro)
}
