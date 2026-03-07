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

// RacaoHandler gerencia os endpoints de racao (recebimentos e consumos).
type RacaoHandler struct {
	feedRepo *repository.FeedRepository
	loteRepo *repository.LoteRepository
	validate *validator.Validate
	logger   *zap.Logger
}

// NewRacaoHandler cria uma nova instancia de RacaoHandler.
func NewRacaoHandler(feedRepo *repository.FeedRepository, loteRepo *repository.LoteRepository, logger *zap.Logger) *RacaoHandler {
	return &RacaoHandler{
		feedRepo: feedRepo,
		loteRepo: loteRepo,
		validate: validator.New(),
		logger:   logger,
	}
}

// ListReceipts godoc
// @Summary      Listar recebimentos de racao
// @Description  Lista recebimentos de racao de um lote com paginacao
// @Tags         racao
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.FeedReceiptResponse}
// @Router       /lotes/{id}/feed_receipts [get]
func (h *RacaoHandler) ListReceipts(c *gin.Context) {
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

	receipts, total, err := h.feedRepo.FindReceiptsByLote(lote.ID, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar recebimentos de racao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar recebimentos de racao.")
		return
	}

	var response []dto.FeedReceiptResponse
	for _, r := range receipts {
		resp := dto.FeedReceiptResponse{
			ID:              r.ID,
			LoteID:          r.LoteID,
			TipoRacaoID:     r.TipoRacaoID,
			QuantidadeKg:    r.QuantidadeKg,
			DataRecebimento: r.DataRecebimento,
			Fornecedor:      r.Fornecedor,
			LoteRacao:       r.LoteRacao,
			Origem:          r.Origem,
			CreatedAt:       r.CreatedAt,
		}
		if r.TipoRacao != nil {
			resp.TipoRacaoNome = r.TipoRacao.Nome
		}
		response = append(response, resp)
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// CreateReceipt godoc
// @Summary      Registrar recebimento de racao
// @Description  Registra um novo recebimento de racao
// @Tags         racao
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateFeedReceiptRequest true "Dados do recebimento"
// @Success      201 {object} dto.SuccessResponse{data=dto.FeedReceiptResponse}
// @Router       /lotes/{id}/feed_receipts [post]
func (h *RacaoHandler) CreateReceipt(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateFeedReceiptRequest
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

	dataRecebimento, err := time.Parse("2006-01-02", req.DataRecebimento)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data invalida. Use formato YYYY-MM-DD.")
		return
	}

	receipt := model.FeedReceipt{
		LoteID:          lote.ID,
		TipoRacaoID:     req.TipoRacaoID,
		QuantidadeKg:    req.QuantidadeKg,
		DataRecebimento: dataRecebimento,
		Fornecedor:      req.Fornecedor,
		LoteRacao:       req.LoteRacao,
		Origem:          req.Origem,
	}
	if receipt.Origem == "" {
		receipt.Origem = "compra"
	}

	if err := h.feedRepo.CreateReceipt(&receipt); err != nil {
		h.logger.Error("Erro ao registrar recebimento de racao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar recebimento de racao.")
		return
	}

	resp := dto.FeedReceiptResponse{
		ID:              receipt.ID,
		LoteID:          receipt.LoteID,
		TipoRacaoID:     receipt.TipoRacaoID,
		QuantidadeKg:    receipt.QuantidadeKg,
		DataRecebimento: receipt.DataRecebimento,
		Fornecedor:      receipt.Fornecedor,
		LoteRacao:       receipt.LoteRacao,
		Origem:          receipt.Origem,
		CreatedAt:       receipt.CreatedAt,
	}

	dto.RespondSuccess(c, http.StatusCreated, resp)
}

// ListConsumptions godoc
// @Summary      Listar consumos de racao
// @Description  Lista consumos de racao de um lote com paginacao
// @Tags         racao
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.FeedConsumptionResponse}
// @Router       /lotes/{id}/feed_consumptions [get]
func (h *RacaoHandler) ListConsumptions(c *gin.Context) {
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

	consumptions, total, err := h.feedRepo.FindConsumptionsByLote(lote.ID, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar consumos de racao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar consumos de racao.")
		return
	}

	var response []dto.FeedConsumptionResponse
	for _, fc := range consumptions {
		response = append(response, dto.FeedConsumptionResponse{
			ID:           fc.ID,
			LoteID:       fc.LoteID,
			Data:         fc.Data,
			QuantidadeKg: fc.QuantidadeKg,
			CreatedAt:    fc.CreatedAt,
		})
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// CreateConsumption godoc
// @Summary      Registrar consumo de racao
// @Description  Registra um novo consumo de racao
// @Tags         racao
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateFeedConsumptionRequest true "Dados do consumo"
// @Success      201 {object} dto.SuccessResponse{data=dto.FeedConsumptionResponse}
// @Router       /lotes/{id}/feed_consumptions [post]
func (h *RacaoHandler) CreateConsumption(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateFeedConsumptionRequest
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

	consumption := model.FeedConsumption{
		LoteID:       lote.ID,
		Data:         data,
		QuantidadeKg: req.QuantidadeKg,
	}

	if err := h.feedRepo.CreateConsumption(&consumption); err != nil {
		h.logger.Error("Erro ao registrar consumo de racao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar consumo de racao.")
		return
	}

	resp := dto.FeedConsumptionResponse{
		ID:           consumption.ID,
		LoteID:       consumption.LoteID,
		Data:         consumption.Data,
		QuantidadeKg: consumption.QuantidadeKg,
		CreatedAt:    consumption.CreatedAt,
	}

	dto.RespondSuccess(c, http.StatusCreated, resp)
}

// Saldo godoc
// @Summary      Saldo de racao
// @Description  Retorna o saldo atual de racao do lote
// @Tags         racao
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=dto.SaldoRacaoResponse}
// @Router       /lotes/{id}/racao/saldo [get]
func (h *RacaoHandler) Saldo(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	recebido, consumido, err := h.feedRepo.SaldoAtual(lote.ID)
	if err != nil {
		h.logger.Error("Erro ao calcular saldo de racao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao calcular saldo de racao.")
		return
	}

	saldo := recebido - consumido

	resp := dto.SaldoRacaoResponse{
		RecebidoTotalKg: recebido,
		ConsumoTotalKg:  consumido,
		SaldoKg:         saldo,
	}

	// Estimar dias restantes
	diasDeVida := lote.DiasDeVida()
	if diasDeVida > 0 && consumido > 0 {
		consumoMedioDiario := consumido / float64(diasDeVida)
		if consumoMedioDiario > 0 {
			dias := saldo / consumoMedioDiario
			resp.DiasEstoqueRestante = &dias
		}
	}

	dto.RespondSuccess(c, http.StatusOK, resp)
}
