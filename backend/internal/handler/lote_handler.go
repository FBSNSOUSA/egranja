package handler

import (
	"errors"
	"net/http"
	"time"

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

// LoteHandler gerencia os endpoints de lotes.
type LoteHandler struct {
	loteRepo        *repository.LoteRepository
	galpaoRepo      *repository.GalpaoRepository
	granjaRepo      *repository.GranjaRepository
	colaboradorRepo *repository.GranjaColaboradorRepository
	indicadores     *service.IndicadoresService
	blockchain      *service.BlockchainService
	validate        *validator.Validate
	logger          *zap.Logger
}

// NewLoteHandler cria uma nova instancia de LoteHandler.
func NewLoteHandler(
	loteRepo *repository.LoteRepository,
	galpaoRepo *repository.GalpaoRepository,
	granjaRepo *repository.GranjaRepository,
	colaboradorRepo *repository.GranjaColaboradorRepository,
	indicadores *service.IndicadoresService,
	blockchain *service.BlockchainService,
	logger *zap.Logger,
) *LoteHandler {
	return &LoteHandler{
		loteRepo:        loteRepo,
		galpaoRepo:      galpaoRepo,
		granjaRepo:      granjaRepo,
		colaboradorRepo: colaboradorRepo,
		indicadores:     indicadores,
		blockchain:      blockchain,
		validate:        validator.New(),
		logger:          logger,
	}
}

// List godoc
// @Summary      Listar lotes
// @Description  Lista lotes acessiveis ao usuario autenticado com paginacao e filtro de status
// @Tags         lotes
// @Produce      json
// @Security     BearerAuth
// @Param        status query string false "Filtro de status (ativo, finalizado)"
// @Param        page query int false "Pagina" default(1)
// @Param        per_page query int false "Itens por pagina" default(20)
// @Success      200 {object} dto.SuccessResponse{data=[]dto.LoteResponse}
// @Router       /lotes [get]
func (h *LoteHandler) List(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	status := c.Query("status")
	page, perPage := dto.ParsePagination(c)

	// Buscar IDs de granjas colaboradas para incluir lotes
	granjaIDs, _ := h.colaboradorRepo.FindGranjaIDsAcessiveis(userID)

	lotes, total, err := h.loteRepo.FindAcessiveis(userID, granjaIDs, status, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar lotes", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar lotes.")
		return
	}

	var response []dto.LoteResponse
	for _, l := range lotes {
		resp := h.buildLoteResponse(&l)
		response = append(response, resp)
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// Create godoc
// @Summary      Criar lote
// @Description  Cria um novo lote de aves
// @Tags         lotes
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body body dto.CreateLoteRequest true "Dados do lote"
// @Success      201 {object} dto.SuccessResponse{data=dto.LoteResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      422 {object} dto.ErrorResponse
// @Router       /lotes [post]
func (h *LoteHandler) Create(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	var req dto.CreateLoteRequest
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

	// Verificar se o galpao pertence ao usuario ou a uma granja colaborada
	galpao, err := h.galpaoRepo.FindByID(req.GalpaoID)
	if err != nil {
		if errors.Is(err, repository.ErrGalpaoNotFound) {
			dto.RespondNotFound(c, "Galpao nao encontrado.")
			return
		}
		h.logger.Error("Erro ao buscar galpao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao verificar galpao.")
		return
	}
	if !h.usuarioTemAcessoGalpao(galpao, userID, "editor") {
		dto.RespondForbidden(c, "Voce nao tem permissao para criar lotes neste galpao.")
		return
	}

	dataAlojamento, err := time.Parse("2006-01-02", req.DataAlojamento)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data de alojamento invalida. Use formato YYYY-MM-DD.")
		return
	}

	dataPrevistaAbate, err := time.Parse("2006-01-02", req.DataPrevistaAbate)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data prevista de abate invalida. Use formato YYYY-MM-DD.")
		return
	}

	lote := model.Lote{
		UsuarioID:         userID,
		GalpaoID:          req.GalpaoID,
		DataAlojamento:    dataAlojamento,
		DataPrevistaAbate: dataPrevistaAbate,
		Quantidade:        req.Quantidade,
		Tipo:              req.Tipo,
		Linhagem:          req.Linhagem,
	}

	if req.PesoInicialG != nil {
		lote.PesoInicialG = *req.PesoInicialG
	}

	if err := h.loteRepo.Create(&lote); err != nil {
		h.logger.Error("Erro ao criar lote", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao criar lote.")
		return
	}

	// Registrar na cadeia de rastreabilidade
	if h.blockchain != nil {
		_ = h.blockchain.RegistrarEvento(lote.ID, "alojamento", map[string]interface{}{
			"quantidade":      lote.Quantidade,
			"tipo":            lote.Tipo,
			"linhagem":        lote.Linhagem,
			"data_alojamento": lote.DataAlojamento.Format("2006-01-02"),
			"peso_inicial_g":  lote.PesoInicialG,
		})
	}

	// Recarregar com galpao
	lote.Galpao = *galpao

	resp := h.buildLoteResponse(&lote)
	dto.RespondSuccess(c, http.StatusCreated, resp)
}

// Get godoc
// @Summary      Detalhes do lote
// @Description  Retorna os detalhes de um lote com indicadores basicos
// @Tags         lotes
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=dto.LoteResponse}
// @Failure      404 {object} dto.ErrorResponse
// @Router       /lotes/{id} [get]
func (h *LoteHandler) Get(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := h.getLoteAutenticado(c, userID)
	if err != nil {
		return // erro ja respondido
	}

	resp := h.buildLoteResponse(lote)
	dto.RespondSuccess(c, http.StatusOK, resp)
}

// Finalizar godoc
// @Summary      Finalizar lote
// @Description  Finaliza um lote ativo
// @Tags         lotes
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.FinalizarLoteRequest true "Dados de finalizacao"
// @Success      200 {object} dto.SuccessResponse{data=dto.LoteResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Router       /lotes/{id}/finalizar [patch]
func (h *LoteHandler) Finalizar(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := h.getLoteAutenticado(c, userID)
	if err != nil {
		return
	}

	if !lote.IsAtivo() {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Lote ja foi finalizado.")
		return
	}

	var req dto.FinalizarLoteRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	if err := h.validate.Struct(req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Erro de validacao.")
		return
	}

	dataFinalizacao, err := time.Parse("2006-01-02", req.DataFinalizacao)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data de finalizacao invalida.")
		return
	}

	lote.Status = "finalizado"
	lote.DataFinalizacao = &dataFinalizacao
	lote.AvesEntregues = &req.AvesEntregues
	lote.PesoTotalEntregue = &req.PesoTotalEntregue

	if err := h.loteRepo.Update(lote); err != nil {
		h.logger.Error("Erro ao finalizar lote", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao finalizar lote.")
		return
	}

	// Registrar na cadeia de rastreabilidade
	if h.blockchain != nil {
		_ = h.blockchain.RegistrarEvento(lote.ID, "finalizacao", map[string]interface{}{
			"data_finalizacao":    dataFinalizacao.Format("2006-01-02"),
			"aves_entregues":     req.AvesEntregues,
			"peso_total_entregue": req.PesoTotalEntregue,
		})
	}

	resp := h.buildLoteResponse(lote)
	dto.RespondSuccess(c, http.StatusOK, resp)
}

// getLoteAutenticado busca um lote pelo ID do path e verifica se o usuario
// e proprietario ou colaborador da granja a qual o galpao do lote pertence.
func (h *LoteHandler) getLoteAutenticado(c *gin.Context, userID uuid.UUID) (*model.Lote, error) {
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

	// Proprietario direto do lote
	if lote.UsuarioID == userID {
		return lote, nil
	}

	// Verificar se e colaborador da granja do galpao
	if lote.Galpao.GranjaID != nil {
		_, colabErr := h.colaboradorRepo.UsuarioTemAcesso(*lote.Galpao.GranjaID, userID)
		if colabErr == nil {
			return lote, nil
		}
	}

	dto.RespondForbidden(c, "Voce nao tem acesso a este lote.")
	return nil, errors.New("acesso negado")
}

// usuarioTemAcessoGalpao verifica se o usuario tem acesso a um galpao.
// Para escrita (editor), verifica se e proprietario ou editor da granja.
// Para leitura, aceita qualquer permissao de colaborador.
func (h *LoteHandler) usuarioTemAcessoGalpao(galpao *model.Galpao, userID uuid.UUID, permissaoMinima string) bool {
	// Proprietario direto
	if galpao.UsuarioID == userID {
		return true
	}
	// Verificar via granja
	if galpao.GranjaID != nil {
		perm, err := h.colaboradorRepo.UsuarioTemAcesso(*galpao.GranjaID, userID)
		if err != nil {
			return false
		}
		if permissaoMinima == "editor" {
			return perm == "editor"
		}
		return true // visualizador ou editor
	}
	return false
}

// buildLoteResponse constroi a resposta de um lote.
func (h *LoteHandler) buildLoteResponse(lote *model.Lote) dto.LoteResponse {
	resp := dto.LoteResponse{
		ID:                lote.ID,
		UsuarioID:         lote.UsuarioID,
		GalpaoID:          lote.GalpaoID,
		GalpaoNome:        lote.Galpao.Nome,
		DataAlojamento:    lote.DataAlojamento,
		DataPrevistaAbate: lote.DataPrevistaAbate,
		Quantidade:        lote.Quantidade,
		Tipo:              lote.Tipo,
		Linhagem:          lote.Linhagem,
		PesoInicialG:      lote.PesoInicialG,
		Status:            lote.Status,
		DiasDeVida:        lote.DiasDeVida(),
		DataFinalizacao:   lote.DataFinalizacao,
		CreatedAt:         lote.CreatedAt,
		UpdatedAt:         lote.UpdatedAt,
	}

	// Calcular mortalidade e aves vivas
	mortalidadeTotal, err := h.loteRepo.GetMortalidadeTotal(lote.ID)
	if err == nil {
		resp.MortalidadeTotal = mortalidadeTotal
		resp.AvesVivas = lote.Quantidade - mortalidadeTotal
	} else {
		resp.AvesVivas = lote.Quantidade
	}

	// Ultimo peso medio
	ultimoPeso, err := h.loteRepo.GetUltimoPesoMedio(lote.ID)
	if err == nil {
		resp.UltimoPesoMedio = ultimoPeso
	}

	return resp
}
