package handler

import (
	"errors"
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// WhatsappHandler gerencia os endpoints de WhatsApp.
type WhatsappHandler struct {
	whatsappRepo *repository.WhatsappRepository
	loteRepo     *repository.LoteRepository
	logger       *zap.Logger
}

// NewWhatsappHandler cria uma nova instancia de WhatsappHandler.
func NewWhatsappHandler(whatsappRepo *repository.WhatsappRepository, loteRepo *repository.LoteRepository, logger *zap.Logger) *WhatsappHandler {
	return &WhatsappHandler{
		whatsappRepo: whatsappRepo,
		loteRepo:     loteRepo,
		logger:       logger,
	}
}

// CreateRecipientRequest representa o payload de adicao de destinatario.
type CreateRecipientRequest struct {
	Numero string  `json:"numero" binding:"required"`
	Nome   *string `json:"nome,omitempty"`
}

// ListRecipients godoc
// @Summary      Listar destinatarios WhatsApp
// @Description  Lista destinatarios de um lote
// @Tags         whatsapp
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]model.WhatsappRecipient}
// @Router       /lotes/{id}/whatsapp_recipients [get]
func (h *WhatsappHandler) ListRecipients(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	recipients, err := h.whatsappRepo.FindRecipientsByLote(lote.ID)
	if err != nil {
		h.logger.Error("Erro ao listar destinatarios", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar destinatarios.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, recipients)
}

// CreateRecipient godoc
// @Summary      Adicionar destinatario WhatsApp
// @Description  Adiciona um destinatario de WhatsApp a um lote
// @Tags         whatsapp
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body CreateRecipientRequest true "Dados do destinatario"
// @Success      201 {object} dto.SuccessResponse{data=model.WhatsappRecipient}
// @Router       /lotes/{id}/whatsapp_recipients [post]
func (h *WhatsappHandler) CreateRecipient(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req CreateRecipientRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	recipient := model.WhatsappRecipient{
		LoteID: lote.ID,
		Numero: req.Numero,
		Nome:   req.Nome,
	}

	if err := h.whatsappRepo.CreateRecipient(&recipient); err != nil {
		h.logger.Error("Erro ao adicionar destinatario", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao adicionar destinatario.")
		return
	}

	dto.RespondSuccess(c, http.StatusCreated, recipient)
}

// DeleteRecipient godoc
// @Summary      Remover destinatario WhatsApp
// @Description  Remove um destinatario de WhatsApp
// @Tags         whatsapp
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        rid path string true "ID do destinatario"
// @Success      200 {object} dto.SuccessResponse
// @Router       /lotes/{id}/whatsapp_recipients/{rid} [delete]
func (h *WhatsappHandler) DeleteRecipient(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	_, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	rid, err := uuid.Parse(c.Param("rid"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID do destinatario invalido.")
		return
	}

	if err := h.whatsappRepo.DeleteRecipient(rid); err != nil {
		if errors.Is(err, repository.ErrWhatsappRecipientNotFound) {
			dto.RespondNotFound(c, "Destinatario nao encontrado.")
			return
		}
		h.logger.Error("Erro ao remover destinatario", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao remover destinatario.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, map[string]string{"message": "Destinatario removido."})
}

// EnviarWhatsapp godoc
// @Summary      Registrar envio via WhatsApp
// @Description  Registra o envio de uma mensagem via WhatsApp
// @Tags         whatsapp
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      201 {object} dto.SuccessResponse
// @Router       /lotes/{id}/enviar_whatsapp [post]
func (h *WhatsappHandler) EnviarWhatsapp(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	_, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	type EnviarRequest struct {
		RecipientID uuid.UUID  `json:"recipient_id" binding:"required"`
		TipoEnvio   string     `json:"tipo_envio" binding:"required"`
		Mensagem    string     `json:"mensagem" binding:"required"`
		PesagemID   *uuid.UUID `json:"pesagem_id,omitempty"`
		MortalidadeID *uuid.UUID `json:"mortalidade_id,omitempty"`
	}

	var req EnviarRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	history := model.WhatsappSendHistory{
		WhatsappRecipientID: req.RecipientID,
		PesagemID:           req.PesagemID,
		MortalidadeID:       req.MortalidadeID,
		Mensagem:            req.Mensagem,
		Status:              "enviado",
		TipoEnvio:           req.TipoEnvio,
	}

	if err := h.whatsappRepo.CreateSendHistory(&history); err != nil {
		h.logger.Error("Erro ao registrar envio WhatsApp", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar envio.")
		return
	}

	dto.RespondSuccess(c, http.StatusCreated, history)
}
