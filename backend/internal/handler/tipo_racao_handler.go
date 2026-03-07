package handler

import (
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// TipoRacaoHandler gerencia os endpoints de tipos de racao.
type TipoRacaoHandler struct {
	tipoRacaoRepo *repository.TipoRacaoRepository
	logger        *zap.Logger
}

// NewTipoRacaoHandler cria uma nova instancia de TipoRacaoHandler.
func NewTipoRacaoHandler(tipoRacaoRepo *repository.TipoRacaoRepository, logger *zap.Logger) *TipoRacaoHandler {
	return &TipoRacaoHandler{
		tipoRacaoRepo: tipoRacaoRepo,
		logger:        logger,
	}
}

// List godoc
// @Summary      Listar tipos de racao
// @Description  Retorna todos os tipos de racao disponiveis
// @Tags         tipos_racao
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SuccessResponse{data=[]model.TipoRacao}
// @Router       /tipos_racao [get]
func (h *TipoRacaoHandler) List(c *gin.Context) {
	tipos, err := h.tipoRacaoRepo.FindAll()
	if err != nil {
		h.logger.Error("Erro ao listar tipos de racao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar tipos de racao.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, tipos)
}
