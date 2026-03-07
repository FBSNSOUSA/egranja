package handler

import (
	"errors"
	"fmt"
	"net/http"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// MensagemHandler gerencia os endpoints de mensagens (chat).
type MensagemHandler struct {
	mensagemRepo *repository.MensagemRepository
	loteRepo     *repository.LoteRepository
	validate     *validator.Validate
	logger       *zap.Logger
}

// NewMensagemHandler cria uma nova instancia de MensagemHandler.
func NewMensagemHandler(mensagemRepo *repository.MensagemRepository, loteRepo *repository.LoteRepository, logger *zap.Logger) *MensagemHandler {
	return &MensagemHandler{
		mensagemRepo: mensagemRepo,
		loteRepo:     loteRepo,
		validate:     validator.New(),
		logger:       logger,
	}
}

// List godoc
// @Summary      Listar mensagens
// @Description  Lista mensagens de um lote com paginacao
// @Tags         mensagens
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        page query int false "Pagina" default(1)
// @Param        per_page query int false "Itens por pagina" default(20)
// @Success      200 {object} dto.SuccessResponse{data=[]dto.MensagemResponse}
// @Router       /lotes/{id}/mensagens [get]
func (h *MensagemHandler) List(c *gin.Context) {
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

	mensagens, total, err := h.mensagemRepo.FindByLote(lote.ID, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar mensagens", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar mensagens.")
		return
	}

	var response []dto.MensagemResponse
	for _, m := range mensagens {
		response = append(response, buildMensagemResponse(&m))
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// Create godoc
// @Summary      Enviar mensagem
// @Description  Envia uma nova mensagem no chat do lote
// @Tags         mensagens
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateMensagemRequest true "Dados da mensagem"
// @Success      201 {object} dto.SuccessResponse{data=dto.MensagemResponse}
// @Router       /lotes/{id}/mensagens [post]
func (h *MensagemHandler) Create(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateMensagemRequest
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

	mensagem := model.Mensagem{
		LoteID:            lote.ID,
		RemetenteID:       userID,
		Tipo:              req.Tipo,
		Conteudo:          req.Conteudo,
		MidiaURL:          req.MidiaURL,
		MidiaThumbnailURL: req.MidiaThumbnailURL,
	}

	if req.Tipo == "solicitacao" {
		status := "pendente"
		mensagem.SolicitacaoStatus = &status
		if req.SolicitacaoPrazo != nil {
			prazo, err := time.Parse("2006-01-02T15:04:05", *req.SolicitacaoPrazo)
			if err == nil {
				mensagem.SolicitacaoPrazo = &prazo
			}
		}
	}

	if err := h.mensagemRepo.Create(&mensagem); err != nil {
		h.logger.Error("Erro ao enviar mensagem", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao enviar mensagem.")
		return
	}

	// Recarregar com remetente
	mensagemCompleta, _ := h.mensagemRepo.FindByID(mensagem.ID)
	if mensagemCompleta != nil {
		resp := buildMensagemResponse(mensagemCompleta)
		dto.RespondSuccess(c, http.StatusCreated, resp)
		return
	}

	dto.RespondSuccess(c, http.StatusCreated, mensagem)
}

// MarcarLida godoc
// @Summary      Marcar mensagem como lida
// @Description  Marca uma mensagem como lida
// @Tags         mensagens
// @Produce      json
// @Security     BearerAuth
// @Param        mid path string true "ID da mensagem"
// @Success      200 {object} dto.SuccessResponse
// @Router       /mensagens/{mid}/lida [patch]
func (h *MensagemHandler) MarcarLida(c *gin.Context) {
	_, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	mid, err := uuid.Parse(c.Param("mid"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID da mensagem invalido.")
		return
	}

	if err := h.mensagemRepo.MarcarLida(mid); err != nil {
		if errors.Is(err, repository.ErrMensagemNotFound) {
			dto.RespondNotFound(c, "Mensagem nao encontrada.")
			return
		}
		h.logger.Error("Erro ao marcar mensagem como lida", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao marcar mensagem como lida.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, map[string]string{"message": "Mensagem marcada como lida."})
}

// CriarVisita godoc
// @Summary      Registrar visita tecnica
// @Description  Registra uma visita tecnica no lote
// @Tags         mensagens
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.VisitaRequest true "Dados da visita"
// @Success      201 {object} dto.SuccessResponse{data=dto.MensagemResponse}
// @Router       /lotes/{id}/visitas [post]
func (h *MensagemHandler) CriarVisita(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.VisitaRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	conteudo := fmt.Sprintf("Visita tecnica em %s", req.DataHora)
	if req.Observacoes != nil {
		conteudo += "\nObservacoes: " + *req.Observacoes
	}

	mensagem := model.Mensagem{
		LoteID:      lote.ID,
		RemetenteID: userID,
		Tipo:        "visita",
		Conteudo:    &conteudo,
	}

	if err := h.mensagemRepo.Create(&mensagem); err != nil {
		h.logger.Error("Erro ao registrar visita", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar visita.")
		return
	}

	mensagemCompleta, _ := h.mensagemRepo.FindByID(mensagem.ID)
	if mensagemCompleta != nil {
		resp := buildMensagemResponse(mensagemCompleta)
		dto.RespondSuccess(c, http.StatusCreated, resp)
		return
	}

	dto.RespondSuccess(c, http.StatusCreated, mensagem)
}

func buildMensagemResponse(m *model.Mensagem) dto.MensagemResponse {
	resp := dto.MensagemResponse{
		ID:                m.ID,
		LoteID:            m.LoteID,
		RemetenteID:       m.RemetenteID,
		RemetenteNome:     m.Remetente.Nome,
		RemetenteTipo:     m.Remetente.Tipo,
		Tipo:              m.Tipo,
		Conteudo:          m.Conteudo,
		MidiaURL:          m.MidiaURL,
		MidiaThumbnailURL: m.MidiaThumbnailURL,
		SolicitacaoStatus: m.SolicitacaoStatus,
		SolicitacaoPrazo:  m.SolicitacaoPrazo,
		Lida:              m.Lida,
		CreatedAt:         m.CreatedAt,
	}
	return resp
}
