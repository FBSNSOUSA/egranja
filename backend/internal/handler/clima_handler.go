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

// ClimaHandler gerencia os endpoints de previsao do tempo.
type ClimaHandler struct {
	climaService    *service.ClimaService
	galpaoRepo      *repository.GalpaoRepository
	colaboradorRepo *repository.GranjaColaboradorRepository
	logger          *zap.Logger
}

// NewClimaHandler cria uma nova instancia de ClimaHandler.
func NewClimaHandler(climaService *service.ClimaService, galpaoRepo *repository.GalpaoRepository, colaboradorRepo *repository.GranjaColaboradorRepository, logger *zap.Logger) *ClimaHandler {
	return &ClimaHandler{
		climaService:    climaService,
		galpaoRepo:      galpaoRepo,
		colaboradorRepo: colaboradorRepo,
		logger:          logger,
	}
}

// Previsao godoc
// @Summary      Previsao do tempo
// @Description  Busca previsao do tempo baseada na latitude/longitude do galpao
// @Tags         clima
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do galpao"
// @Success      200 {object} dto.SuccessResponse{data=dto.PrevisaoTempoResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      404 {object} dto.ErrorResponse
// @Router       /galpoes/{id}/clima/previsao [get]
func (h *ClimaHandler) Previsao(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	galpao, err := h.getGalpaoAutenticado(c, userID)
	if err != nil {
		return
	}

	if galpao.Latitude == nil || galpao.Longitude == nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Galpao nao possui coordenadas geograficas cadastradas.")
		return
	}

	previsao, err := h.climaService.BuscarPrevisao(c.Request.Context(), *galpao.Latitude, *galpao.Longitude)
	if err != nil {
		h.logger.Error("Erro ao buscar previsao do tempo", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar previsao do tempo.")
		return
	}

	// Salvar no cache (async, nao bloqueia resposta)
	if galpao.GranjaID != nil {
		go func() {
			if err := h.climaService.SalvarPrevisao(*galpao.GranjaID, previsao); err != nil {
				h.logger.Error("Erro ao salvar previsao em cache", zap.Error(err))
			}
		}()
	}

	response := h.climaService.ToPrevisaoResponse(galpao.ID, previsao)
	dto.RespondSuccess(c, http.StatusOK, response)
}

// Alertas godoc
// @Summary      Alertas climaticos
// @Description  Retorna alertas climaticos ativos baseados na previsao do tempo
// @Tags         clima
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do galpao"
// @Success      200 {object} dto.SuccessResponse{data=dto.AlertasClimaListResponse}
// @Failure      400 {object} dto.ErrorResponse
// @Router       /galpoes/{id}/clima/alertas [get]
func (h *ClimaHandler) Alertas(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	galpao, err := h.getGalpaoAutenticado(c, userID)
	if err != nil {
		return
	}

	if galpao.Latitude == nil || galpao.Longitude == nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Galpao nao possui coordenadas geograficas cadastradas.")
		return
	}

	previsao, err := h.climaService.BuscarPrevisao(c.Request.Context(), *galpao.Latitude, *galpao.Longitude)
	if err != nil {
		h.logger.Error("Erro ao buscar previsao do tempo para alertas", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar previsao do tempo.")
		return
	}

	alertas := h.climaService.VerificarAlertasClima(previsao)
	response := h.climaService.ToAlertasResponse(galpao.ID, alertas)

	dto.RespondSuccess(c, http.StatusOK, response)
}

// galpaoResult guarda os dados minimos do galpao para os handlers de clima.
type galpaoResult struct {
	ID        uuid.UUID
	GranjaID  *uuid.UUID
	Latitude  *float64
	Longitude *float64
}

// getGalpaoAutenticado busca um galpao pelo ID do path e verifica pertence ao usuario.
func (h *ClimaHandler) getGalpaoAutenticado(c *gin.Context, userID uuid.UUID) (*galpaoResult, error) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID invalido.")
		return nil, err
	}

	galpao, err := h.galpaoRepo.FindByID(id)
	if err != nil {
		if errors.Is(err, repository.ErrGalpaoNotFound) {
			dto.RespondNotFound(c, "Galpao nao encontrado.")
			return nil, err
		}
		h.logger.Error("Erro ao buscar galpao", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar galpao.")
		return nil, err
	}

	if galpao.UsuarioID != userID {
		if galpao.GranjaID != nil {
			_, colabErr := h.colaboradorRepo.UsuarioTemAcesso(*galpao.GranjaID, userID)
			if colabErr != nil {
				dto.RespondForbidden(c, "Voce nao tem acesso a este galpao.")
				return nil, errors.New("acesso negado")
			}
		} else {
			dto.RespondForbidden(c, "Voce nao tem acesso a este galpao.")
			return nil, errors.New("acesso negado")
		}
	}

	return &galpaoResult{
		ID:        galpao.ID,
		GranjaID:  galpao.GranjaID,
		Latitude:  galpao.Latitude,
		Longitude: galpao.Longitude,
	}, nil
}
