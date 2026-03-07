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
	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"go.uber.org/zap"
)

// ChecklistHandler gerencia os endpoints de checklists.
type ChecklistHandler struct {
	checklistRepo *repository.ChecklistRepository
	loteRepo      *repository.LoteRepository
	validate      *validator.Validate
	logger        *zap.Logger
}

// NewChecklistHandler cria uma nova instancia de ChecklistHandler.
func NewChecklistHandler(checklistRepo *repository.ChecklistRepository, loteRepo *repository.LoteRepository, logger *zap.Logger) *ChecklistHandler {
	return &ChecklistHandler{
		checklistRepo: checklistRepo,
		loteRepo:      loteRepo,
		validate:      validator.New(),
		logger:        logger,
	}
}

// List godoc
// @Summary      Listar checklists
// @Description  Lista checklists de um lote com paginacao
// @Tags         checklist
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=[]dto.ChecklistResponse}
// @Router       /lotes/{id}/checklists [get]
func (h *ChecklistHandler) List(c *gin.Context) {
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

	checklists, total, err := h.checklistRepo.FindByLotePeriodo(lote.ID, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar checklists", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar checklists.")
		return
	}

	var response []dto.ChecklistResponse
	for _, cl := range checklists {
		response = append(response, dto.ChecklistResponse{
			ID:                   cl.ID,
			LoteID:               cl.LoteID,
			Data:                 cl.Data,
			Itens:                cl.Itens,
			Completado:           cl.Completado,
			PorcentagemConclusao: cl.PorcentagemConclusao(),
			CreatedAt:            cl.CreatedAt,
			UpdatedAt:            cl.UpdatedAt,
		})
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// Create godoc
// @Summary      Criar/atualizar checklist
// @Description  Cria ou atualiza o checklist do dia
// @Tags         checklist
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        body body dto.CreateChecklistRequest true "Dados do checklist"
// @Success      201 {object} dto.SuccessResponse{data=dto.ChecklistResponse}
// @Router       /lotes/{id}/checklists [post]
func (h *ChecklistHandler) Create(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	var req dto.CreateChecklistRequest
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

	// Converter itens para ChecklistItem
	var items []model.ChecklistItem
	for _, item := range req.Itens {
		items = append(items, model.ChecklistItem{
			Descricao:  item.Descricao,
			Completado: item.Completado,
		})
	}

	itensJSON, err := json.Marshal(items)
	if err != nil {
		dto.RespondInternalError(c, "Erro ao processar itens.")
		return
	}

	// Verificar se existe checklist com a mesma data - se sim, atualizar
	existing, err := h.checklistRepo.FindByLoteData(lote.ID, data)
	if err == nil && existing != nil {
		existing.Itens = itensJSON
		// Verificar se todos os itens estao completados
		allComplete := true
		for _, item := range items {
			if !item.Completado {
				allComplete = false
				break
			}
		}
		existing.Completado = allComplete

		if err := h.checklistRepo.Update(existing); err != nil {
			h.logger.Error("Erro ao atualizar checklist", zap.Error(err))
			dto.RespondInternalError(c, "Erro ao atualizar checklist.")
			return
		}

		resp := dto.ChecklistResponse{
			ID:                   existing.ID,
			LoteID:               existing.LoteID,
			Data:                 existing.Data,
			Itens:                existing.Itens,
			Completado:           existing.Completado,
			PorcentagemConclusao: existing.PorcentagemConclusao(),
			CreatedAt:            existing.CreatedAt,
			UpdatedAt:            existing.UpdatedAt,
		}
		dto.RespondSuccess(c, http.StatusOK, resp)
		return
	}

	// Criar novo
	allComplete := true
	for _, item := range items {
		if !item.Completado {
			allComplete = false
			break
		}
	}

	checklist := model.Checklist{
		LoteID:     lote.ID,
		Data:       data,
		Itens:      itensJSON,
		Completado: allComplete,
	}

	if err := h.checklistRepo.Create(&checklist); err != nil {
		h.logger.Error("Erro ao criar checklist", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao criar checklist.")
		return
	}

	resp := dto.ChecklistResponse{
		ID:                   checklist.ID,
		LoteID:               checklist.LoteID,
		Data:                 checklist.Data,
		Itens:                checklist.Itens,
		Completado:           checklist.Completado,
		PorcentagemConclusao: checklist.PorcentagemConclusao(),
		CreatedAt:            checklist.CreatedAt,
		UpdatedAt:            checklist.UpdatedAt,
	}

	dto.RespondSuccess(c, http.StatusCreated, resp)
}

// UpdateByData godoc
// @Summary      Atualizar checklist por data
// @Description  Atualiza os itens de um checklist pelo lote e data
// @Tags         checklist
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Param        data path string true "Data (YYYY-MM-DD)"
// @Param        body body dto.UpdateChecklistRequest true "Itens atualizados"
// @Success      200 {object} dto.SuccessResponse{data=dto.ChecklistResponse}
// @Router       /lotes/{id}/checklists/{data} [patch]
func (h *ChecklistHandler) UpdateByData(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	lote, err := getLoteAutenticadoHelper(c, h.loteRepo, userID, h.logger)
	if err != nil {
		return
	}

	dataStr := c.Param("data")
	data, err := time.Parse("2006-01-02", dataStr)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Data invalida. Use formato YYYY-MM-DD.")
		return
	}

	checklist, err := h.checklistRepo.FindByLoteData(lote.ID, data)
	if err != nil {
		if errors.Is(err, repository.ErrChecklistNotFound) {
			dto.RespondNotFound(c, "Checklist nao encontrado para esta data.")
			return
		}
		h.logger.Error("Erro ao buscar checklist", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar checklist.")
		return
	}

	var req dto.UpdateChecklistRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	var items []model.ChecklistItem
	allComplete := true
	for _, item := range req.Itens {
		items = append(items, model.ChecklistItem{
			Descricao:  item.Descricao,
			Completado: item.Completado,
		})
		if !item.Completado {
			allComplete = false
		}
	}

	itensJSON, err := json.Marshal(items)
	if err != nil {
		dto.RespondInternalError(c, "Erro ao processar itens.")
		return
	}

	checklist.Itens = itensJSON
	checklist.Completado = allComplete

	if err := h.checklistRepo.Update(checklist); err != nil {
		h.logger.Error("Erro ao atualizar checklist", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao atualizar checklist.")
		return
	}

	resp := dto.ChecklistResponse{
		ID:                   checklist.ID,
		LoteID:               checklist.LoteID,
		Data:                 checklist.Data,
		Itens:                checklist.Itens,
		Completado:           checklist.Completado,
		PorcentagemConclusao: checklist.PorcentagemConclusao(),
		CreatedAt:            checklist.CreatedAt,
		UpdatedAt:            checklist.UpdatedAt,
	}

	dto.RespondSuccess(c, http.StatusOK, resp)
}
