package handler

import (
	"errors"
	"net/http"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.uber.org/zap"
)

// AguaHandler gerencia os endpoints de consumo de agua.
type AguaHandler struct {
	waterRepo *repository.WaterRepository
	loteRepo  *repository.LoteRepository
	validate  *validator.Validate
	logger    *zap.Logger
}

// NewAguaHandler cria uma nova instancia de AguaHandler.
func NewAguaHandler(waterRepo *repository.WaterRepository, loteRepo *repository.LoteRepository, logger *zap.Logger) *AguaHandler {
	return &AguaHandler{
		waterRepo: waterRepo,
		loteRepo:  loteRepo,
		validate:  validator.New(),
		logger:    logger,
	}
}

// List godoc
// @Summary      Listar consumos de agua
// @Description  Lista consumos de agua de um lote com paginacao
// @Tags         agua
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.WaterConsumptionResponse}
// @Router       /lotes/{id}/water_consumptions [get]
func (h *AguaHandler) List(c *gin.Context) {
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

	consumptions, total, err := h.waterRepo.FindByLote(lote.ID, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar consumos de agua", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar consumos de agua.")
		return
	}

	var response []dto.WaterConsumptionResponse
	for _, wc := range consumptions {
		response = append(response, dto.WaterConsumptionResponse{
			ID:               wc.ID,
			LoteID:           wc.LoteID,
			Data:             wc.Data,
			QuantidadeLitros: wc.QuantidadeLitros,
			CreatedAt:        wc.CreatedAt,
		})
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// Create godoc
// @Summary      Registrar consumo de agua
// @Description  Registra um novo consumo de agua
// @Tags         agua
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateWaterConsumptionRequest true "Dados do consumo"
// @Success      201 {object} dto.SuccessResponse{data=dto.WaterConsumptionResponse}
// @Router       /lotes/{id}/water_consumptions [post]
func (h *AguaHandler) Create(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateWaterConsumptionRequest
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

	consumption := model.WaterConsumption{
		LoteID:           lote.ID,
		Data:             data,
		QuantidadeLitros: req.QuantidadeLitros,
	}

	if err := h.waterRepo.Create(&consumption); err != nil {
		h.logger.Error("Erro ao registrar consumo de agua", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar consumo de agua.")
		return
	}

	resp := dto.WaterConsumptionResponse{
		ID:               consumption.ID,
		LoteID:           consumption.LoteID,
		Data:             consumption.Data,
		QuantidadeLitros: consumption.QuantidadeLitros,
		CreatedAt:        consumption.CreatedAt,
	}

	dto.RespondSuccess(c, http.StatusCreated, resp)
}
