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

// PesagemHandler gerencia os endpoints de pesagens.
type PesagemHandler struct {
	pesagemRepo *repository.PesagemRepository
	loteRepo    *repository.LoteRepository
	blockchain  *service.BlockchainService
	validate    *validator.Validate
	logger      *zap.Logger
}

// NewPesagemHandler cria uma nova instancia de PesagemHandler.
func NewPesagemHandler(pesagemRepo *repository.PesagemRepository, loteRepo *repository.LoteRepository, blockchain *service.BlockchainService, logger *zap.Logger) *PesagemHandler {
	return &PesagemHandler{
		pesagemRepo: pesagemRepo,
		loteRepo:    loteRepo,
		blockchain:  blockchain,
		validate:    validator.New(),
		logger:      logger,
	}
}

// List godoc
// @Summary      Listar pesagens
// @Description  Lista pesagens de um lote com paginacao
// @Tags         pesagens
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        page query int false "Pagina" default(1)
// @Param        per_page query int false "Itens por pagina" default(20)
// @Success      200 {object} dto.SuccessResponse{data=[]dto.PesagemResponse}
// @Router       /lotes/{id}/pesagens [get]
func (h *PesagemHandler) List(c *gin.Context) {
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

	pesagens, total, err := h.pesagemRepo.FindByLote(lote.ID, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar pesagens", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar pesagens.")
		return
	}

	var response []dto.PesagemResponse
	for _, p := range pesagens {
		response = append(response, buildPesagemResponse(&p))
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// Create godoc
// @Summary      Criar pesagem
// @Description  Cria uma nova pesagem com items (amostras) nested
// @Tags         pesagens
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreatePesagemRequest true "Dados da pesagem"
// @Success      201 {object} dto.SuccessResponse{data=dto.PesagemResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Router       /lotes/{id}/pesagens [post]
func (h *PesagemHandler) Create(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreatePesagemRequest
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

	// Calcular totais a partir dos items
	var quantidadeTotal int
	var pesoTotal float64
	var items []model.PesagemItem

	for _, item := range req.Items {
		quantidadeTotal += item.Quantidade
		pesoTotal += item.Peso
		items = append(items, model.PesagemItem{
			Quantidade: item.Quantidade,
			Peso:       item.Peso,
		})
	}

	pesagem := model.Pesagem{
		LoteID:          lote.ID,
		Data:            data,
		QuantidadeTotal: quantidadeTotal,
		PesoTotal:       pesoTotal,
		Items:           items,
	}
	pesagem.CalculaPesoMedio()

	if err := h.pesagemRepo.Create(&pesagem); err != nil {
		h.logger.Error("Erro ao criar pesagem", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao criar pesagem.")
		return
	}

	// Registrar na cadeia de rastreabilidade
	if h.blockchain != nil {
		_ = h.blockchain.RegistrarEvento(lote.ID, "pesagem", map[string]interface{}{
			"data":       data.Format("2006-01-02"),
			"quantidade": quantidadeTotal,
			"peso_total": pesoTotal,
			"peso_medio": pesagem.PesoMedio,
		})
	}

	resp := buildPesagemResponse(&pesagem)
	dto.RespondSuccess(c, http.StatusCreated, resp)
}

// Get godoc
// @Summary      Detalhes da pesagem
// @Description  Retorna os detalhes de uma pesagem com seus items
// @Tags         pesagens
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        pid path string true "ID da pesagem"
// @Success      200 {object} dto.SuccessResponse{data=dto.PesagemResponse}
// @Router       /lotes/{id}/pesagens/{pid} [get]
func (h *PesagemHandler) Get(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	_, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	pid, err := uuid.Parse(c.Param("pid"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID da pesagem invalido.")
		return
	}

	pesagem, err := h.pesagemRepo.FindByID(pid)
	if err != nil {
		if errors.Is(err, repository.ErrPesagemNotFound) {
			dto.RespondNotFound(c, "Pesagem nao encontrada.")
			return
		}
		h.logger.Error("Erro ao buscar pesagem", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar pesagem.")
		return
	}

	resp := buildPesagemResponse(pesagem)
	dto.RespondSuccess(c, http.StatusOK, resp)
}

func buildPesagemResponse(p *model.Pesagem) dto.PesagemResponse {
	resp := dto.PesagemResponse{
		ID:              p.ID,
		LoteID:          p.LoteID,
		Data:            p.Data,
		QuantidadeTotal: p.QuantidadeTotal,
		PesoTotal:       p.PesoTotal,
		PesoMedio:       p.PesoMedio,
		CreatedAt:       p.CreatedAt,
	}

	for _, item := range p.Items {
		resp.Items = append(resp.Items, dto.PesagemItemResponse{
			ID:         item.ID,
			Quantidade: item.Quantidade,
			Peso:       item.Peso,
			PesoMedio:  item.PesoMedio,
		})
	}

	return resp
}

// getLoteAutenticadoHelper e uma funcao helper para buscar e validar lote.
func getLoteAutenticadoHelper(c *gin.Context, loteRepo *repository.LoteRepository, userID uuid.UUID, logger *zap.Logger) (*model.Lote, error) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID do lote invalido.")
		return nil, err
	}

	lote, err := loteRepo.FindByID(id)
	if err != nil {
		if errors.Is(err, repository.ErrLoteNotFound) {
			dto.RespondNotFound(c, "Lote nao encontrado.")
			return nil, err
		}
		logger.Error("Erro ao buscar lote", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar lote.")
		return nil, err
	}

	if lote.UsuarioID != userID {
		dto.RespondForbidden(c, "Voce nao tem acesso a este lote.")
		return nil, errors.New("acesso negado")
	}

	return lote, nil
}
