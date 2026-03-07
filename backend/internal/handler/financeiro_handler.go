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
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// FinanceiroHandler gerencia os endpoints financeiros.
type FinanceiroHandler struct {
	custoRepo       *repository.CustoRepository
	remuneracaoRepo *repository.RemuneracaoRepository
	loteRepo        *repository.LoteRepository
	validate        *validator.Validate
	logger          *zap.Logger
}

// NewFinanceiroHandler cria uma nova instancia de FinanceiroHandler.
func NewFinanceiroHandler(
	custoRepo *repository.CustoRepository,
	remuneracaoRepo *repository.RemuneracaoRepository,
	loteRepo *repository.LoteRepository,
	logger *zap.Logger,
) *FinanceiroHandler {
	return &FinanceiroHandler{
		custoRepo:       custoRepo,
		remuneracaoRepo: remuneracaoRepo,
		loteRepo:        loteRepo,
		validate:        validator.New(),
		logger:          logger,
	}
}

// ListCustos godoc
// @Summary      Listar custos
// @Description  Lista custos de producao de um lote
// @Tags         financeiro
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.CustoResponse}
// @Router       /lotes/{id}/custos [get]
func (h *FinanceiroHandler) ListCustos(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	custos, err := h.custoRepo.FindByLote(lote.ID)
	if err != nil {
		h.logger.Error("Erro ao listar custos", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar custos.")
		return
	}

	var response []dto.CustoResponse
	for _, cu := range custos {
		response = append(response, dto.CustoResponse{
			ID: cu.ID, LoteID: cu.LoteID, Categoria: cu.Categoria,
			Descricao: cu.Descricao, Valor: cu.Valor, Data: cu.Data,
			CreatedAt: cu.CreatedAt,
		})
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// CreateCusto godoc
// @Summary      Registrar custo
// @Description  Registra um custo de producao no lote
// @Tags         financeiro
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateCustoRequest true "Dados do custo"
// @Success      201 {object} dto.SuccessResponse{data=dto.CustoResponse}
// @Router       /lotes/{id}/custos [post]
func (h *FinanceiroHandler) CreateCusto(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateCustoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	if err := h.validate.Struct(req); err != nil {
		var validationErrors validator.ValidationErrors
		if errors.As(err, &validationErrors) {
			details := make([]dto.ErrorDetail, 0, len(validationErrors))
			for _, fe := range validationErrors {
				details = append(details, dto.ErrorDetail{Field: fe.Field(), Message: translateValidationError(fe)})
			}
			dto.RespondValidationError(c, details)
			return
		}
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Erro de validacao.")
		return
	}

	custo := model.CustoLote{
		LoteID:    lote.ID,
		Categoria: req.Categoria,
		Descricao: req.Descricao,
		Valor:     req.Valor,
	}

	if req.Data != nil {
		data, err := time.Parse("2006-01-02", *req.Data)
		if err == nil {
			custo.Data = &data
		}
	}

	if err := h.custoRepo.Create(&custo); err != nil {
		h.logger.Error("Erro ao registrar custo", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar custo.")
		return
	}

	dto.RespondSuccess(c, http.StatusCreated, dto.CustoResponse{
		ID: custo.ID, LoteID: custo.LoteID, Categoria: custo.Categoria,
		Descricao: custo.Descricao, Valor: custo.Valor, Data: custo.Data,
		CreatedAt: custo.CreatedAt,
	})
}

// DeleteCusto godoc
// @Summary      Remover custo
// @Description  Remove um custo de producao
// @Tags         financeiro
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        cid path string true "ID do custo"
// @Success      200 {object} dto.SuccessResponse
// @Router       /lotes/{id}/custos/{cid} [delete]
func (h *FinanceiroHandler) DeleteCusto(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	_, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	cid, err := uuid.Parse(c.Param("cid"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID do custo invalido.")
		return
	}

	if err := h.custoRepo.Delete(cid); err != nil {
		if errors.Is(err, repository.ErrCustoNotFound) {
			dto.RespondNotFound(c, "Custo nao encontrado.")
			return
		}
		h.logger.Error("Erro ao remover custo", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao remover custo.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, map[string]string{"message": "Custo removido."})
}

// CreateRemuneracao godoc
// @Summary      Registrar remuneracao
// @Description  Registra a remuneracao da integradora pelo lote
// @Tags         financeiro
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateRemuneracaoRequest true "Dados da remuneracao"
// @Success      201 {object} dto.SuccessResponse{data=dto.RemuneracaoResponse}
// @Router       /lotes/{id}/remuneracao [post]
func (h *FinanceiroHandler) CreateRemuneracao(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateRemuneracaoRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	if err := h.validate.Struct(req); err != nil {
		var validationErrors validator.ValidationErrors
		if errors.As(err, &validationErrors) {
			details := make([]dto.ErrorDetail, 0, len(validationErrors))
			for _, fe := range validationErrors {
				details = append(details, dto.ErrorDetail{Field: fe.Field(), Message: translateValidationError(fe)})
			}
			dto.RespondValidationError(c, details)
			return
		}
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Erro de validacao.")
		return
	}

	remuneracao := model.Remuneracao{
		LoteID:     lote.ID,
		Valor:      req.Valor,
		Tipo:       req.Tipo,
		Observacao: req.Observacao,
	}

	if req.DataPagamento != nil {
		dp, err := time.Parse("2006-01-02", *req.DataPagamento)
		if err == nil {
			remuneracao.DataPagamento = &dp
		}
	}

	if err := h.remuneracaoRepo.Create(&remuneracao); err != nil {
		h.logger.Error("Erro ao registrar remuneracao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar remuneracao.")
		return
	}

	dto.RespondSuccess(c, http.StatusCreated, dto.RemuneracaoResponse{
		ID: remuneracao.ID, LoteID: remuneracao.LoteID, Valor: remuneracao.Valor,
		Tipo: remuneracao.Tipo, DataPagamento: remuneracao.DataPagamento,
		Observacao: remuneracao.Observacao, CreatedAt: remuneracao.CreatedAt,
	})
}

// ResumoFinanceiro godoc
// @Summary      Resumo financeiro
// @Description  Retorna o resumo financeiro do lote (custos, receitas, resultado)
// @Tags         financeiro
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=dto.ResumoFinanceiroResponse}
// @Router       /lotes/{id}/financeiro/resumo [get]
func (h *FinanceiroHandler) ResumoFinanceiro(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	custoTotal, err := h.custoRepo.TotalByLote(lote.ID)
	if err != nil {
		h.logger.Error("Erro ao calcular custo total", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao calcular resumo financeiro.")
		return
	}

	receitaTotal, err := h.remuneracaoRepo.TotalByLote(lote.ID)
	if err != nil {
		h.logger.Error("Erro ao calcular receita total", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao calcular resumo financeiro.")
		return
	}

	custosPorCategoria, _ := h.custoRepo.TotalByCategoria(lote.ID)

	resp := dto.ResumoFinanceiroResponse{
		LoteID:           lote.ID,
		CustoTotal:       custoTotal,
		ReceitaTotal:     receitaTotal,
		ResultadoLiquido: receitaTotal - custoTotal,
	}

	// Calcular custo por kg e por ave
	mortalidade, _ := h.loteRepo.GetMortalidadeTotal(lote.ID)
	avesVivas := lote.Quantidade - mortalidade

	if avesVivas > 0 && custoTotal > 0 {
		custoPorAve := custoTotal / float64(avesVivas)
		resp.CustoPorAve = &custoPorAve
	}

	if lote.PesoTotalEntregue != nil && *lote.PesoTotalEntregue > 0 {
		custoPorKg := custoTotal / *lote.PesoTotalEntregue
		resp.CustoPorKg = &custoPorKg

		margemPorKg := (receitaTotal - custoTotal) / *lote.PesoTotalEntregue
		resp.MargemPorKg = &margemPorKg
	}

	if avesVivas > 0 {
		margemPorAve := (receitaTotal - custoTotal) / float64(avesVivas)
		resp.MargemPorAve = &margemPorAve
	}

	for _, cc := range custosPorCategoria {
		resp.CustosPorCategoria = append(resp.CustosPorCategoria, dto.CustoCategoriaDTO{
			Categoria: cc.Categoria,
			Total:     cc.Total,
		})
	}

	dto.RespondSuccess(c, http.StatusOK, resp)
}

// RelatorioFinanceiro godoc
// @Summary      Relatorio financeiro
// @Description  Retorna dados detalhados para relatorio financeiro
// @Tags         financeiro
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse
// @Router       /lotes/{id}/financeiro/relatorio [get]
func (h *FinanceiroHandler) RelatorioFinanceiro(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	custos, _ := h.custoRepo.FindByLote(lote.ID)
	remuneracoes, _ := h.remuneracaoRepo.FindByLote(lote.ID)
	custoTotal, _ := h.custoRepo.TotalByLote(lote.ID)
	receitaTotal, _ := h.remuneracaoRepo.TotalByLote(lote.ID)
	custosPorCategoria, _ := h.custoRepo.TotalByCategoria(lote.ID)

	relatorio := map[string]interface{}{
		"lote_id":              lote.ID,
		"custos":               custos,
		"remuneracoes":         remuneracoes,
		"custo_total":          custoTotal,
		"receita_total":        receitaTotal,
		"resultado_liquido":    receitaTotal - custoTotal,
		"custos_por_categoria": custosPorCategoria,
	}

	dto.RespondSuccess(c, http.StatusOK, relatorio)
}
