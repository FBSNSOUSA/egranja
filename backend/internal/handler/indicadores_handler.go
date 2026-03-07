package handler

import (
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// IndicadoresHandler gerencia os endpoints de indicadores zootecnicos.
type IndicadoresHandler struct {
	indicadores *service.IndicadoresService
	loteRepo    *repository.LoteRepository
	logger      *zap.Logger
}

// NewIndicadoresHandler cria uma nova instancia de IndicadoresHandler.
func NewIndicadoresHandler(indicadores *service.IndicadoresService, loteRepo *repository.LoteRepository, logger *zap.Logger) *IndicadoresHandler {
	return &IndicadoresHandler{
		indicadores: indicadores,
		loteRepo:    loteRepo,
		logger:      logger,
	}
}

// Get godoc
// @Summary      Indicadores do lote
// @Description  Retorna todos os indicadores zootecnicos do lote (ICA, IEA, GPD, IEP, etc.)
// @Tags         indicadores
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=dto.LoteIndicadoresResponse}
// @Failure      404 {object} dto.ErrorResponse
// @Router       /lotes/{id}/indicadores [get]
func (h *IndicadoresHandler) Get(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	indicadores, err := h.indicadores.Calcular(lote)
	if err != nil {
		h.logger.Error("Erro ao calcular indicadores", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao calcular indicadores.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, indicadores)
}
