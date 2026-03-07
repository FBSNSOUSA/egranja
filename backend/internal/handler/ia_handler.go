package handler

import (
	"errors"
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// IAHandler gerencia os endpoints de IA (assistente virtual Gemini).
type IAHandler struct {
	iaService *service.IAService
	iaRepo    *repository.IARepository
	loteRepo  *repository.LoteRepository
	validate  *validator.Validate
	logger    *zap.Logger
	maxCalls  int
}

// NewIAHandler cria uma nova instancia de IAHandler.
func NewIAHandler(
	iaService *service.IAService,
	iaRepo *repository.IARepository,
	loteRepo *repository.LoteRepository,
	maxCalls int,
	logger *zap.Logger,
) *IAHandler {
	return &IAHandler{
		iaService: iaService,
		iaRepo:    iaRepo,
		loteRepo:  loteRepo,
		validate:  validator.New(),
		logger:    logger,
		maxCalls:  maxCalls,
	}
}

// Consultar godoc
// @Summary      Consultar IA
// @Description  Envia uma pergunta ao assistente de IA com contexto do lote
// @Tags         ia
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.IAConsultaRequest true "Pergunta"
// @Success      200 {object} dto.SuccessResponse{data=dto.IAConsultaResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      429 {object} dto.ErrorResponse
// @Router       /lotes/{id}/ia/consultar [post]
func (h *IAHandler) Consultar(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := h.getLoteAutenticado(c, userID)
	if err != nil {
		return
	}

	// Verificar limite diario
	count, err := h.iaRepo.CountByUsuarioHoje(userID)
	if err != nil {
		h.logger.Error("Erro ao verificar limite de IA", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao verificar limite de uso.")
		return
	}
	if count >= int64(h.maxCalls) {
		dto.RespondError(c, http.StatusTooManyRequests, "RATE_LIMIT", "Limite diario de consultas a IA atingido.")
		return
	}

	var req dto.IAConsultaRequest
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

	// Montar contexto do lote
	contextoLote := h.iaService.BuildContextoLoteMap(lote)

	// Consultar IA
	resposta, tokens, err := h.iaService.Consultar(c.Request.Context(), req.Pergunta, contextoLote)
	if err != nil {
		h.logger.Error("Erro ao consultar IA", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao consultar assistente de IA.")
		return
	}

	// Salvar interacao
	tokensPtr := tokens
	interacao := &model.IAInteracao{
		LoteID:       &lote.ID,
		UsuarioID:    userID,
		Tipo:         "chat_assistente",
		PromptResumo: &req.Pergunta,
		Resposta:     resposta,
		TokensUsados: &tokensPtr,
	}

	if err := h.iaRepo.Create(interacao); err != nil {
		h.logger.Error("Erro ao salvar interacao IA", zap.Error(err))
		// Nao retorna erro, pois a resposta ja foi obtida
	}

	dto.RespondSuccess(c, http.StatusOK, dto.IAConsultaResponse{
		Resposta: resposta,
		Tokens:   tokens,
	})
}

// Analisar godoc
// @Summary      Analise proativa de IA
// @Description  Gera analise proativa automatica dos indicadores do lote
// @Tags         ia
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=dto.IAAnaliseResponse}
// @Router       /lotes/{id}/ia/analisar [post]
func (h *IAHandler) Analisar(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := h.getLoteAutenticado(c, userID)
	if err != nil {
		return
	}

	resposta, tokens, err := h.iaService.AnalisarIndicadores(c.Request.Context(), lote.ID, nil)
	if err != nil {
		h.logger.Error("Erro ao analisar indicadores via IA", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao gerar analise de IA.")
		return
	}

	// Salvar interacao
	tokensPtr := tokens
	promptResumo := "Analise proativa de indicadores"
	interacao := &model.IAInteracao{
		LoteID:       &lote.ID,
		UsuarioID:    userID,
		Tipo:         "analise",
		PromptResumo: &promptResumo,
		Resposta:     resposta,
		TokensUsados: &tokensPtr,
	}

	if err := h.iaRepo.Create(interacao); err != nil {
		h.logger.Error("Erro ao salvar interacao IA", zap.Error(err))
	}

	dto.RespondSuccess(c, http.StatusOK, dto.IAAnaliseResponse{
		Resposta: resposta,
		Tokens:   tokens,
	})
}

// Historico godoc
// @Summary      Historico de interacoes IA
// @Description  Lista interacoes com a IA para um lote
// @Tags         ia
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        page query int false "Pagina" default(1)
// @Param        per_page query int false "Itens por pagina" default(20)
// @Success      200 {object} dto.SuccessResponse{data=[]dto.IAInteracaoResponse}
// @Router       /lotes/{id}/ia/historico [get]
func (h *IAHandler) Historico(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := h.getLoteAutenticado(c, userID)
	if err != nil {
		return
	}

	page, perPage := dto.ParsePagination(c)

	interacoes, total, err := h.iaRepo.FindByLoteID(lote.ID, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao buscar historico IA", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar historico de interacoes.")
		return
	}

	var response []dto.IAInteracaoResponse
	for _, i := range interacoes {
		pergunta := ""
		if i.PromptResumo != nil {
			pergunta = *i.PromptResumo
		}
		tokens := 0
		if i.TokensUsados != nil {
			tokens = *i.TokensUsados
		}
		response = append(response, dto.IAInteracaoResponse{
			ID:        i.ID,
			Pergunta:  pergunta,
			Resposta:  i.Resposta,
			Tipo:      i.Tipo,
			Modelo:    i.Modelo,
			Tokens:    tokens,
			CreatedAt: i.CreatedAt,
		})
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// getLoteAutenticado busca um lote pelo ID do path e verifica pertence ao usuario.
func (h *IAHandler) getLoteAutenticado(c *gin.Context, userID uuid.UUID) (*model.Lote, error) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID invalido.")
		return nil, err
	}

	lote, err := h.loteRepo.FindByID(id)
	if err != nil {
		if errors.Is(err, repository.ErrLoteNotFound) {
			dto.RespondNotFound(c, "Lote nao encontrado.")
			return nil, err
		}
		h.logger.Error("Erro ao buscar lote", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar lote.")
		return nil, err
	}

	if lote.UsuarioID != userID {
		dto.RespondForbidden(c, "Voce nao tem acesso a este lote.")
		return nil, errors.New("acesso negado")
	}

	return lote, nil
}
