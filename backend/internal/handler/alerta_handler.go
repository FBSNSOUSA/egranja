package handler

import (
	"errors"
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// AlertaHandler gerencia os endpoints de alertas automaticos.
type AlertaHandler struct {
	alertaService *service.AlertaService
	loteRepo      *repository.LoteRepository
	logger        *zap.Logger
}

// NewAlertaHandler cria uma nova instancia de AlertaHandler.
func NewAlertaHandler(
	alertaService *service.AlertaService,
	loteRepo *repository.LoteRepository,
	logger *zap.Logger,
) *AlertaHandler {
	return &AlertaHandler{
		alertaService: alertaService,
		loteRepo:      loteRepo,
		logger:        logger,
	}
}

// ListByLote godoc
// @Summary      Listar alertas de um lote
// @Description  Lista todos os alertas ativos de um lote (calculados em tempo real)
// @Tags         alertas
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]service.Alerta}
// @Router       /lotes/{id}/alertas [get]
func (h *AlertaHandler) ListByLote(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	loteIDStr := c.Param("id")
	loteID, err := uuid.Parse(loteIDStr)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID do lote invalido.")
		return
	}

	lote, err := h.loteRepo.FindByID(loteID)
	if err != nil {
		if errors.Is(err, repository.ErrLoteNotFound) {
			dto.RespondNotFound(c, "Lote nao encontrado.")
			return
		}
		h.logger.Error("Erro ao buscar lote para alertas", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar lote.")
		return
	}

	// Verificar acesso: produtor do lote ou tecnico
	userTipo, _ := middleware.GetUserTipoFromContext(c)
	if lote.UsuarioID != userID && userTipo != "tecnico" {
		dto.RespondForbidden(c, "Voce nao tem acesso a este lote.")
		return
	}

	alertas := h.alertaService.VerificarAlertas(lote)

	if alertas == nil {
		alertas = []service.Alerta{}
	}

	dto.RespondSuccess(c, http.StatusOK, alertas)
}

// ListAll godoc
// @Summary      Listar todos os alertas do usuario
// @Description  Lista alertas de todos os lotes do usuario (produtor: seus lotes, tecnico: lotes vinculados)
// @Tags         alertas
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SuccessResponse{data=[]service.Alerta}
// @Router       /alertas [get]
func (h *AlertaHandler) ListAll(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	userTipo, _ := middleware.GetUserTipoFromContext(c)

	alertas, err := h.alertaService.VerificarAlertasTodosLotes(userID, userTipo)
	if err != nil {
		h.logger.Error("Erro ao verificar alertas", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao verificar alertas.")
		return
	}

	if alertas == nil {
		alertas = []service.Alerta{}
	}

	dto.RespondSuccess(c, http.StatusOK, alertas)
}
