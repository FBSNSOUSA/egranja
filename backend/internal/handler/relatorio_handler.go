package handler

import (
	"fmt"
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// RelatorioHandler gerencia os endpoints de relatorios.
type RelatorioHandler struct {
	relatorioService *service.RelatorioService
	loteRepo         *repository.LoteRepository
	logger           *zap.Logger
}

// NewRelatorioHandler cria uma nova instancia de RelatorioHandler.
func NewRelatorioHandler(relatorioService *service.RelatorioService, loteRepo *repository.LoteRepository, logger *zap.Logger) *RelatorioHandler {
	return &RelatorioHandler{
		relatorioService: relatorioService,
		loteRepo:         loteRepo,
		logger:           logger,
	}
}

// Fechamento godoc
// @Summary      Relatorio de fechamento
// @Description  Gera o relatorio de fechamento de lote (dados ou PDF)
// @Tags         relatorios
// @Produce      json,application/pdf
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        format query string false "Formato: json ou pdf" default(json)
// @Success      200 {object} dto.SuccessResponse
// @Router       /lotes/{id}/relatorio/fechamento [get]
func (h *RelatorioHandler) Fechamento(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	format := c.DefaultQuery("format", "json")

	if format == "pdf" {
		pdfBytes, err := h.relatorioService.GerarRelatorioPDF(lote)
		if err != nil {
			h.logger.Error("Erro ao gerar PDF", zap.Error(err))
			dto.RespondInternalError(c, "Erro ao gerar relatorio PDF.")
			return
		}

		c.Header("Content-Type", "application/pdf")
		c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=fechamento_%s.pdf", lote.ID.String()[:8]))
		c.Data(http.StatusOK, "application/pdf", pdfBytes)
		return
	}

	fechamento, err := h.relatorioService.GerarFechamento(lote)
	if err != nil {
		h.logger.Error("Erro ao gerar fechamento", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao gerar relatorio de fechamento.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, fechamento)
}

// Comparativo godoc
// @Summary      Comparativo entre lotes
// @Description  Compara o lote com lotes anteriores do mesmo galpao
// @Tags         relatorios
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse
// @Router       /lotes/{id}/relatorio/comparativo [get]
func (h *RelatorioHandler) Comparativo(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	comparativo, err := h.relatorioService.GerarComparativo(lote)
	if err != nil {
		h.logger.Error("Erro ao gerar comparativo", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao gerar comparativo.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, comparativo)
}

// ExportCSV godoc
// @Summary      Exportar dados em CSV
// @Description  Exporta dados brutos do lote em formato CSV
// @Tags         relatorios
// @Produce      text/csv
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {file} text/csv
// @Router       /lotes/{id}/exportar/csv [get]
func (h *RelatorioHandler) ExportCSV(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	csvBytes, err := h.relatorioService.ExportarCSV(lote)
	if err != nil {
		h.logger.Error("Erro ao exportar CSV", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao exportar CSV.")
		return
	}

	c.Header("Content-Type", "text/csv; charset=utf-8")
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=lote_%s.csv", lote.ID.String()[:8]))
	c.Data(http.StatusOK, "text/csv", csvBytes)
}
