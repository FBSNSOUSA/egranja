package handler

import (
	"errors"
	"net/http"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// IoTHandler gerencia os endpoints de leituras IoT.
type IoTHandler struct {
	iotRepo    *repository.IoTRepository
	galpaoRepo *repository.GalpaoRepository
	logger     *zap.Logger
}

// NewIoTHandler cria uma nova instancia de IoTHandler.
func NewIoTHandler(iotRepo *repository.IoTRepository, galpaoRepo *repository.GalpaoRepository, logger *zap.Logger) *IoTHandler {
	return &IoTHandler{
		iotRepo:    iotRepo,
		galpaoRepo: galpaoRepo,
		logger:     logger,
	}
}

// ListReadings godoc
// @Summary      Listar leituras IoT
// @Description  Lista leituras de sensores de um galpao com filtro de periodo
// @Tags         iot
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do galpao"
// @Param        from query string false "Data/hora inicio (YYYY-MM-DDTHH:MM:SS)"
// @Param        to query string false "Data/hora fim (YYYY-MM-DDTHH:MM:SS)"
// @Param        page query int false "Pagina" default(1)
// @Param        per_page query int false "Itens por pagina" default(20)
// @Success      200 {object} dto.SuccessResponse{data=[]dto.IoTReadingResponse}
// @Router       /galpoes/{id}/iot/readings [get]
func (h *IoTHandler) ListReadings(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	galpao, err := h.getGalpaoAutenticado(c, userID)
	if err != nil {
		return
	}

	var from, to time.Time
	if fromStr := c.Query("from"); fromStr != "" {
		from, err = time.Parse("2006-01-02T15:04:05", fromStr)
		if err != nil {
			dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Parametro 'from' invalido. Use formato YYYY-MM-DDTHH:MM:SS.")
			return
		}
	}
	if toStr := c.Query("to"); toStr != "" {
		to, err = time.Parse("2006-01-02T15:04:05", toStr)
		if err != nil {
			dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Parametro 'to' invalido. Use formato YYYY-MM-DDTHH:MM:SS.")
			return
		}
	}

	page, perPage := dto.ParsePagination(c)

	readings, total, err := h.iotRepo.FindByGalpaoID(galpao.ID, from, to, page, perPage)
	if err != nil {
		h.logger.Error("Erro ao listar leituras IoT", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar leituras IoT.")
		return
	}

	var response []dto.IoTReadingResponse
	for _, r := range readings {
		response = append(response, dto.IoTReadingResponse{
			ID:         r.ID,
			GalpaoID:   r.GalpaoID,
			SensorTipo: r.SensorTipo,
			Valor:      r.Valor,
			Unidade:    r.Unidade,
			Timestamp:  r.Timestamp,
		})
	}

	meta := dto.NewPaginationMeta(page, perPage, total)
	dto.RespondSuccessWithPagination(c, response, meta)
}

// Latest godoc
// @Summary      Ultimas leituras IoT
// @Description  Retorna a ultima leitura de cada tipo de sensor do galpao
// @Tags         iot
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do galpao"
// @Success      200 {object} dto.SuccessResponse{data=dto.IoTLatestResponse}
// @Router       /galpoes/{id}/iot/latest [get]
func (h *IoTHandler) Latest(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	galpao, err := h.getGalpaoAutenticado(c, userID)
	if err != nil {
		return
	}

	readings, err := h.iotRepo.FindLatestByGalpao(galpao.ID)
	if err != nil {
		h.logger.Error("Erro ao buscar ultimas leituras IoT", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar ultimas leituras.")
		return
	}

	response := dto.IoTLatestResponse{
		GalpaoID: galpao.ID,
		Sensores: make([]dto.IoTReadingResponse, 0, len(readings)),
	}

	for _, r := range readings {
		response.Sensores = append(response.Sensores, dto.IoTReadingResponse{
			ID:         r.ID,
			GalpaoID:   r.GalpaoID,
			SensorTipo: r.SensorTipo,
			Valor:      r.Valor,
			Unidade:    r.Unidade,
			Timestamp:  r.Timestamp,
		})
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// Historico godoc
// @Summary      Historico agregado IoT
// @Description  Retorna dados agregados por hora ou dia para graficos
// @Tags         iot
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do galpao"
// @Param        from query string true "Data/hora inicio (YYYY-MM-DDTHH:MM:SS)"
// @Param        to query string true "Data/hora fim (YYYY-MM-DDTHH:MM:SS)"
// @Param        intervalo query string true "Intervalo de agregacao (hora, dia)"
// @Success      200 {object} dto.SuccessResponse{data=dto.IoTHistoricoResponse}
// @Router       /galpoes/{id}/iot/historico [get]
func (h *IoTHandler) Historico(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	galpao, err := h.getGalpaoAutenticado(c, userID)
	if err != nil {
		return
	}

	fromStr := c.Query("from")
	toStr := c.Query("to")
	intervalo := c.Query("intervalo")

	if fromStr == "" || toStr == "" {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Parametros 'from' e 'to' sao obrigatorios.")
		return
	}

	if intervalo == "" {
		intervalo = "hora"
	}
	if intervalo != "hora" && intervalo != "dia" {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Parametro 'intervalo' deve ser 'hora' ou 'dia'.")
		return
	}

	from, err := time.Parse("2006-01-02T15:04:05", fromStr)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Parametro 'from' invalido. Use formato YYYY-MM-DDTHH:MM:SS.")
		return
	}
	to, err := time.Parse("2006-01-02T15:04:05", toStr)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Parametro 'to' invalido. Use formato YYYY-MM-DDTHH:MM:SS.")
		return
	}

	agregados, err := h.iotRepo.FindAgregado(galpao.ID, from, to, intervalo)
	if err != nil {
		h.logger.Error("Erro ao buscar historico agregado IoT", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar historico agregado.")
		return
	}

	response := dto.IoTHistoricoResponse{
		GalpaoID:  galpao.ID,
		Intervalo: intervalo,
		Dados:     make([]dto.IoTAgregadoItem, 0, len(agregados)),
	}

	for _, a := range agregados {
		response.Dados = append(response.Dados, dto.IoTAgregadoItem{
			Periodo:    a.Periodo,
			SensorTipo: a.SensorTipo,
			Media:      a.Media,
			Minimo:     a.Minimo,
			Maximo:     a.Maximo,
			Contagem:   a.Contagem,
		})
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// getGalpaoAutenticado busca um galpao pelo ID do path e verifica pertence ao usuario.
func (h *IoTHandler) getGalpaoAutenticado(c *gin.Context, userID uuid.UUID) (*struct {
	ID uuid.UUID
}, error) {
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
		dto.RespondForbidden(c, "Voce nao tem acesso a este galpao.")
		return nil, errors.New("acesso negado")
	}

	return &struct{ ID uuid.UUID }{ID: galpao.ID}, nil
}
