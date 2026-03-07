package handler

import (
	"encoding/json"
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

// SanidadeHandler gerencia os endpoints de sanidade (vacinacoes, medicamentos, visitantes, rastreabilidade).
type SanidadeHandler struct {
	vacinacaoRepo   *repository.VacinacaoRepository
	medicamentoRepo *repository.MedicamentoRepository
	visitanteRepo   *repository.VisitanteRepository
	granjaRepo      *repository.GranjaRepository
	loteRepo        *repository.LoteRepository
	colaboradorRepo *repository.GranjaColaboradorRepository
	blockchain      *service.BlockchainService
	validate        *validator.Validate
	logger          *zap.Logger
}

// NewSanidadeHandler cria uma nova instancia de SanidadeHandler.
func NewSanidadeHandler(
	vacinacaoRepo *repository.VacinacaoRepository,
	medicamentoRepo *repository.MedicamentoRepository,
	visitanteRepo *repository.VisitanteRepository,
	granjaRepo *repository.GranjaRepository,
	loteRepo *repository.LoteRepository,
	colaboradorRepo *repository.GranjaColaboradorRepository,
	blockchain *service.BlockchainService,
	logger *zap.Logger,
) *SanidadeHandler {
	return &SanidadeHandler{
		vacinacaoRepo:   vacinacaoRepo,
		medicamentoRepo: medicamentoRepo,
		visitanteRepo:   visitanteRepo,
		granjaRepo:      granjaRepo,
		loteRepo:        loteRepo,
		colaboradorRepo: colaboradorRepo,
		blockchain:      blockchain,
		validate:        validator.New(),
		logger:          logger,
	}
}

// granjaAcessivel verifica se o usuario e proprietario ou colaborador da granja.
func (h *SanidadeHandler) granjaAcessivel(granja *model.Granja, userID uuid.UUID) bool {
	if granja.UsuarioID == userID {
		return true
	}
	_, err := h.colaboradorRepo.UsuarioTemAcesso(granja.ID, userID)
	return err == nil
}

// ListVacinacoes godoc
// @Summary      Listar vacinacoes
// @Description  Lista vacinacoes de um lote
// @Tags         sanidade
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.VacinacaoResponse}
// @Router       /lotes/{id}/vacinacoes [get]
func (h *SanidadeHandler) ListVacinacoes(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	vacinacoes, err := h.vacinacaoRepo.FindByLote(lote.ID)
	if err != nil {
		h.logger.Error("Erro ao listar vacinacoes", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar vacinacoes.")
		return
	}

	var response []dto.VacinacaoResponse
	for _, v := range vacinacoes {
		response = append(response, dto.VacinacaoResponse{
			ID:               v.ID,
			LoteID:           v.LoteID,
			Data:             v.Data,
			Vacina:           v.Vacina,
			LoteProduto:      v.LoteProduto,
			ViaAdministracao: v.ViaAdministracao,
			Responsavel:      v.Responsavel,
			Observacao:       v.Observacao,
			CreatedAt:        v.CreatedAt,
		})
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// CreateVacinacao godoc
// @Summary      Registrar vacinacao
// @Description  Registra uma nova vacinacao no lote
// @Tags         sanidade
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateVacinacaoRequest true "Dados da vacinacao"
// @Success      201 {object} dto.SuccessResponse{data=dto.VacinacaoResponse}
// @Router       /lotes/{id}/vacinacoes [post]
func (h *SanidadeHandler) CreateVacinacao(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateVacinacaoRequest
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

	data, err := time.Parse("2006-01-02", req.Data)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data invalida.")
		return
	}

	vacinacao := model.Vacinacao{
		LoteID:           lote.ID,
		Data:             data,
		Vacina:           req.Vacina,
		LoteProduto:      req.LoteProduto,
		ViaAdministracao: req.ViaAdministracao,
		Responsavel:      req.Responsavel,
		Observacao:       req.Observacao,
	}

	if err := h.vacinacaoRepo.Create(&vacinacao); err != nil {
		h.logger.Error("Erro ao registrar vacinacao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar vacinacao.")
		return
	}

	// Registrar na cadeia de rastreabilidade
	if h.blockchain != nil {
		_ = h.blockchain.RegistrarEvento(lote.ID, "vacinacao", map[string]interface{}{
			"vacina": req.Vacina, "data": req.Data,
		})
	}

	dto.RespondSuccess(c, http.StatusCreated, dto.VacinacaoResponse{
		ID: vacinacao.ID, LoteID: vacinacao.LoteID, Data: vacinacao.Data,
		Vacina: vacinacao.Vacina, LoteProduto: vacinacao.LoteProduto,
		ViaAdministracao: vacinacao.ViaAdministracao, Responsavel: vacinacao.Responsavel,
		Observacao: vacinacao.Observacao, CreatedAt: vacinacao.CreatedAt,
	})
}

// ListMedicamentos godoc
// @Summary      Listar medicamentos
// @Description  Lista medicamentos de um lote
// @Tags         sanidade
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.MedicamentoResponse}
// @Router       /lotes/{id}/medicamentos [get]
func (h *SanidadeHandler) ListMedicamentos(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	medicamentos, err := h.medicamentoRepo.FindByLote(lote.ID)
	if err != nil {
		h.logger.Error("Erro ao listar medicamentos", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar medicamentos.")
		return
	}

	medsEmCarencia, _ := h.medicamentoRepo.MedicamentosEmCarencia(lote.ID)
	carenciaIDs := make(map[uuid.UUID]bool)
	for _, m := range medsEmCarencia {
		carenciaIDs[m.ID] = true
	}

	var response []dto.MedicamentoResponse
	for _, m := range medicamentos {
		response = append(response, dto.MedicamentoResponse{
			ID: m.ID, LoteID: m.LoteID, DataInicio: m.DataInicio, DataFim: m.DataFim,
			Medicamento: m.Medicamento, Dosagem: m.Dosagem, Via: m.Via,
			PeriodoCarenciaDias: m.PeriodoCarenciaDias, Responsavel: m.Responsavel,
			Observacao: m.Observacao, EmCarencia: carenciaIDs[m.ID], CreatedAt: m.CreatedAt,
		})
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// CreateMedicamento godoc
// @Summary      Registrar medicamento
// @Description  Registra uso de medicamento no lote
// @Tags         sanidade
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateMedicamentoRequest true "Dados do medicamento"
// @Success      201 {object} dto.SuccessResponse{data=dto.MedicamentoResponse}
// @Router       /lotes/{id}/medicamentos [post]
func (h *SanidadeHandler) CreateMedicamento(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateMedicamentoRequest
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

	dataInicio, err := time.Parse("2006-01-02", req.DataInicio)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data inicio invalida.")
		return
	}

	med := model.Medicamento{
		LoteID: lote.ID, DataInicio: dataInicio, Medicamento: req.Medicamento,
		Dosagem: req.Dosagem, Via: req.Via, PeriodoCarenciaDias: req.PeriodoCarenciaDias,
		Responsavel: req.Responsavel, Observacao: req.Observacao,
	}

	if req.DataFim != nil {
		df, err := time.Parse("2006-01-02", *req.DataFim)
		if err == nil {
			med.DataFim = &df
		}
	}

	if err := h.medicamentoRepo.Create(&med); err != nil {
		h.logger.Error("Erro ao registrar medicamento", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar medicamento.")
		return
	}

	// Registrar na cadeia de rastreabilidade
	if h.blockchain != nil {
		_ = h.blockchain.RegistrarEvento(lote.ID, "medicamento", map[string]interface{}{
			"medicamento": req.Medicamento, "data_inicio": req.DataInicio,
		})
	}

	dto.RespondSuccess(c, http.StatusCreated, dto.MedicamentoResponse{
		ID: med.ID, LoteID: med.LoteID, DataInicio: med.DataInicio, DataFim: med.DataFim,
		Medicamento: med.Medicamento, Dosagem: med.Dosagem, Via: med.Via,
		PeriodoCarenciaDias: med.PeriodoCarenciaDias, Responsavel: med.Responsavel,
		Observacao: med.Observacao, CreatedAt: med.CreatedAt,
	})
}

// ListVisitantes godoc
// @Summary      Listar visitantes
// @Description  Lista visitantes de uma granja
// @Tags         sanidade
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID da granja"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.VisitanteResponse}
// @Router       /granjas/{id}/visitantes [get]
func (h *SanidadeHandler) ListVisitantes(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	granjaID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID invalido.")
		return
	}

	granja, err := h.granjaRepo.FindByID(granjaID)
	if err != nil {
		dto.RespondNotFound(c, "Granja nao encontrada.")
		return
	}
	if !h.granjaAcessivel(granja, userID) {
		dto.RespondForbidden(c, "Acesso negado.")
		return
	}

	page, perPage := dto.ParsePagination(c)

	visitantes, total, err := h.visitanteRepo.FindByGranja(granjaID, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar visitantes", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar visitantes.")
		return
	}

	var response []dto.VisitanteResponse
	for _, v := range visitantes {
		response = append(response, dto.VisitanteResponse{
			ID: v.ID, GranjaID: v.GranjaID, Nome: v.Nome, Documento: v.Documento,
			Origem: v.Origem, Motivo: v.Motivo, UltimoContatoAves: v.UltimoContatoAves,
			PlacaVeiculo: v.PlacaVeiculo, DataEntrada: v.DataEntrada, DataSaida: v.DataSaida,
			Observacao: v.Observacao, CreatedAt: v.CreatedAt,
		})
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// CreateVisitante godoc
// @Summary      Registrar visitante
// @Description  Registra entrada de visitante na granja
// @Tags         sanidade
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID da granja"
// @Param        body body dto.CreateVisitanteRequest true "Dados do visitante"
// @Success      201 {object} dto.SuccessResponse{data=dto.VisitanteResponse}
// @Router       /granjas/{id}/visitantes [post]
func (h *SanidadeHandler) CreateVisitante(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	granjaID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID invalido.")
		return
	}

	granja, err := h.granjaRepo.FindByID(granjaID)
	if err != nil {
		dto.RespondNotFound(c, "Granja nao encontrada.")
		return
	}
	if !h.granjaAcessivel(granja, userID) {
		dto.RespondForbidden(c, "Acesso negado.")
		return
	}

	var req dto.CreateVisitanteRequest
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

	dataEntrada, err := time.Parse("2006-01-02T15:04:05", req.DataEntrada)
	if err != nil {
		dataEntrada, err = time.Parse("2006-01-02", req.DataEntrada)
		if err != nil {
			dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data de entrada invalida.")
			return
		}
	}

	visitante := model.Visitante{
		GranjaID:     granjaID,
		Nome:         req.Nome,
		Documento:    req.Documento,
		Origem:       req.Origem,
		Motivo:       req.Motivo,
		PlacaVeiculo: req.PlacaVeiculo,
		DataEntrada:  dataEntrada,
		Observacao:   req.Observacao,
	}

	if req.UltimoContatoAves != nil {
		uca, err := time.Parse("2006-01-02", *req.UltimoContatoAves)
		if err == nil {
			visitante.UltimoContatoAves = &uca
		}
	}

	if err := h.visitanteRepo.Create(&visitante); err != nil {
		h.logger.Error("Erro ao registrar visitante", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar visitante.")
		return
	}

	dto.RespondSuccess(c, http.StatusCreated, dto.VisitanteResponse{
		ID: visitante.ID, GranjaID: visitante.GranjaID, Nome: visitante.Nome,
		Documento: visitante.Documento, Origem: visitante.Origem, Motivo: visitante.Motivo,
		UltimoContatoAves: visitante.UltimoContatoAves, PlacaVeiculo: visitante.PlacaVeiculo,
		DataEntrada: visitante.DataEntrada, Observacao: visitante.Observacao,
		CreatedAt: visitante.CreatedAt,
	})
}

// RegistrarSaidaVisitante godoc
// @Summary      Registrar saida de visitante
// @Description  Registra a saida de um visitante da granja
// @Tags         sanidade
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID da granja"
// @Param        vid path string true "ID do visitante"
// @Success      200 {object} dto.SuccessResponse
// @Router       /granjas/{id}/visitantes/{vid}/saida [patch]
func (h *SanidadeHandler) RegistrarSaidaVisitante(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	granjaID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID invalido.")
		return
	}

	granja, err := h.granjaRepo.FindByID(granjaID)
	if err != nil {
		dto.RespondNotFound(c, "Granja nao encontrada.")
		return
	}
	if !h.granjaAcessivel(granja, userID) {
		dto.RespondForbidden(c, "Acesso negado.")
		return
	}

	vid, err := uuid.Parse(c.Param("vid"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID do visitante invalido.")
		return
	}

	if err := h.visitanteRepo.RegistrarSaida(vid); err != nil {
		if errors.Is(err, repository.ErrVisitanteNotFound) {
			dto.RespondNotFound(c, "Visitante nao encontrado.")
			return
		}
		h.logger.Error("Erro ao registrar saida", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao registrar saida.")
		return
	}

	dto.RespondSuccess(c, http.StatusOK, map[string]string{"message": "Saida registrada."})
}

// GetRastreabilidade godoc
// @Summary      Cadeia de rastreabilidade
// @Description  Retorna a cadeia de rastreabilidade completa do lote
// @Tags         sanidade
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=dto.RastreabilidadeResponse}
// @Router       /lotes/{id}/rastreabilidade [get]
func (h *SanidadeHandler) GetRastreabilidade(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	chains, integra, err := h.blockchain.GetCadeia(lote.ID)
	if err != nil {
		h.logger.Error("Erro ao buscar rastreabilidade", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar rastreabilidade.")
		return
	}

	var cadeia []dto.RastreabilidadeItemDTO
	for _, ch := range chains {
		var dados interface{}
		_ = json.Unmarshal(ch.Dados, &dados)

		cadeia = append(cadeia, dto.RastreabilidadeItemDTO{
			ID:           ch.ID,
			Evento:       ch.Evento,
			Dados:        dados,
			HashAtual:    ch.HashAtual,
			HashAnterior: ch.HashAnterior,
			CreatedAt:    ch.CreatedAt,
		})
	}

	resp := dto.RastreabilidadeResponse{
		LoteID:  lote.ID,
		Cadeia:  cadeia,
		Integra: integra,
	}

	dto.RespondSuccess(c, http.StatusOK, resp)
}

// GetGTA godoc
// @Summary      Gerar GTA
// @Description  Gera os dados para o formulario GTA do lote
// @Tags         sanidade
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse
// @Router       /lotes/{id}/gta [get]
func (h *SanidadeHandler) GetGTA(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	// Buscar vacinacoes e medicamentos para o GTA
	vacinacoes, _ := h.vacinacaoRepo.FindByLote(lote.ID)
	medicamentos, _ := h.medicamentoRepo.FindByLote(lote.ID)

	mortalidadeTotal, _ := h.loteRepo.GetMortalidadeTotal(lote.ID)
	avesVivas := lote.Quantidade - mortalidadeTotal

	gtaData := map[string]interface{}{
		"lote_id":           lote.ID,
		"galpao":            lote.Galpao.Nome,
		"data_alojamento":   lote.DataAlojamento.Format("02/01/2006"),
		"tipo":              lote.Tipo,
		"linhagem":          lote.Linhagem,
		"aves_alojadas":     lote.Quantidade,
		"aves_vivas":        avesVivas,
		"total_vacinacoes":  len(vacinacoes),
		"total_medicamentos": len(medicamentos),
		"vacinacoes":        vacinacoes,
		"medicamentos":      medicamentos,
	}

	dto.RespondSuccess(c, http.StatusOK, gtaData)
}
