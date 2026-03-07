package handler

import (
	"net/http"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// TecnicoHandler gerencia os endpoints exclusivos para tecnicos.
type TecnicoHandler struct {
	loteRepo    *repository.LoteRepository
	usuarioRepo *repository.UsuarioRepository
	indicadores *service.IndicadoresService
	logger      *zap.Logger
}

// NewTecnicoHandler cria uma nova instancia de TecnicoHandler.
func NewTecnicoHandler(
	loteRepo *repository.LoteRepository,
	usuarioRepo *repository.UsuarioRepository,
	indicadores *service.IndicadoresService,
	logger *zap.Logger,
) *TecnicoHandler {
	return &TecnicoHandler{
		loteRepo:    loteRepo,
		usuarioRepo: usuarioRepo,
		indicadores: indicadores,
		logger:      logger,
	}
}

// AlertaDTO representa um alerta para o tecnico.
type AlertaDTO struct {
	LoteID      uuid.UUID `json:"lote_id"`
	GalpaoNome  string    `json:"galpao_nome"`
	Tipo        string    `json:"tipo"`
	Mensagem    string    `json:"mensagem"`
	Prioridade  string    `json:"prioridade"`
	DiasDeVida  int       `json:"dias_de_vida"`
}

// ListLotes godoc
// @Summary      Lotes dos produtores vinculados
// @Description  Lista todos os lotes ativos dos produtores vinculados ao tecnico
// @Tags         tecnico
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SuccessResponse{data=[]dto.LoteResponse}
// @Router       /tecnico/lotes [get]
func (h *TecnicoHandler) ListLotes(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	// Buscar produtores vinculados ao tecnico
	produtores, err := h.usuarioRepo.FindProdutoresByTecnicoID(userID)
	if err != nil {
		h.logger.Error("Erro ao buscar produtores do tecnico", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar produtores.")
		return
	}

	var produtorIDs []uuid.UUID
	for _, p := range produtores {
		produtorIDs = append(produtorIDs, p.ID)
	}

	if len(produtorIDs) == 0 {
		dto.RespondSuccess(c, http.StatusOK, []interface{}{})
		return
	}

	lotes, err := h.loteRepo.FindAtivosByUsuarios(produtorIDs)
	if err != nil {
		h.logger.Error("Erro ao listar lotes dos produtores", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao listar lotes.")
		return
	}

	var response []dto.LoteResponse
	for _, l := range lotes {
		mortalidade, _ := h.loteRepo.GetMortalidadeTotal(l.ID)
		ultimoPeso, _ := h.loteRepo.GetUltimoPesoMedio(l.ID)

		resp := dto.LoteResponse{
			ID:                l.ID,
			UsuarioID:         l.UsuarioID,
			GalpaoID:          l.GalpaoID,
			GalpaoNome:        l.Galpao.Nome,
			DataAlojamento:    l.DataAlojamento,
			DataPrevistaAbate: l.DataPrevistaAbate,
			Quantidade:        l.Quantidade,
			Tipo:              l.Tipo,
			Linhagem:          l.Linhagem,
			PesoInicialG:      l.PesoInicialG,
			Status:            l.Status,
			DiasDeVida:        l.DiasDeVida(),
			AvesVivas:         l.Quantidade - mortalidade,
			MortalidadeTotal:  mortalidade,
			UltimoPesoMedio:   ultimoPeso,
			CreatedAt:         l.CreatedAt,
			UpdatedAt:         l.UpdatedAt,
		}
		response = append(response, resp)
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// ListAlertas godoc
// @Summary      Alertas dos produtores vinculados
// @Description  Lista alertas ativos de todos os produtores vinculados ao tecnico
// @Tags         tecnico
// @Produce      json
// @Security     BearerAuth
// @Success      200 {object} dto.SuccessResponse{data=[]AlertaDTO}
// @Router       /tecnico/alertas [get]
func (h *TecnicoHandler) ListAlertas(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	produtores, err := h.usuarioRepo.FindProdutoresByTecnicoID(userID)
	if err != nil {
		h.logger.Error("Erro ao buscar produtores do tecnico", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar produtores.")
		return
	}

	var produtorIDs []uuid.UUID
	for _, p := range produtores {
		produtorIDs = append(produtorIDs, p.ID)
	}

	if len(produtorIDs) == 0 {
		dto.RespondSuccess(c, http.StatusOK, []interface{}{})
		return
	}

	lotes, err := h.loteRepo.FindAtivosByUsuarios(produtorIDs)
	if err != nil {
		h.logger.Error("Erro ao buscar lotes para alertas", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar alertas.")
		return
	}

	var alertas []AlertaDTO

	for _, l := range lotes {
		indicadores, err := h.indicadores.Calcular(&l)
		if err != nil {
			continue
		}

		// Mortalidade alta (> 3%)
		if indicadores.MortalidadePct > 3 {
			alertas = append(alertas, AlertaDTO{
				LoteID: l.ID, GalpaoNome: l.Galpao.Nome,
				Tipo: "mortalidade_alta", Prioridade: "ALTA",
				Mensagem:   "Mortalidade acumulada acima de 3%.",
				DiasDeVida: indicadores.DiasDeVida,
			})
		}

		// Peso baixo (< 90% do padrao)
		if indicadores.DesvioPesoPct != nil && *indicadores.DesvioPesoPct < -10 {
			prioridade := "ALTA"
			if *indicadores.DesvioPesoPct < -20 {
				prioridade = "CRITICA"
			}
			alertas = append(alertas, AlertaDTO{
				LoteID: l.ID, GalpaoNome: l.Galpao.Nome,
				Tipo: "peso_baixo", Prioridade: prioridade,
				Mensagem:   "Peso abaixo do padrao da linhagem.",
				DiasDeVida: indicadores.DiasDeVida,
			})
		}

		// Racao acabando (< 2 dias)
		if indicadores.DiasEstoqueRacao != nil && *indicadores.DiasEstoqueRacao < 2 {
			alertas = append(alertas, AlertaDTO{
				LoteID: l.ID, GalpaoNome: l.Galpao.Nome,
				Tipo: "racao_acabando", Prioridade: "ALTA",
				Mensagem:   "Estoque de racao para menos de 2 dias.",
				DiasDeVida: indicadores.DiasDeVida,
			})
		}

		// Proximo ao abate (< 5 dias)
		diasParaAbate := int(l.DataPrevistaAbate.Sub(time.Now()).Hours() / 24)
		if diasParaAbate >= 0 && diasParaAbate < 5 {
			alertas = append(alertas, AlertaDTO{
				LoteID: l.ID, GalpaoNome: l.Galpao.Nome,
				Tipo: "proximo_abate", Prioridade: "MEDIA",
				Mensagem:   "Lote proximo da data prevista de abate.",
				DiasDeVida: indicadores.DiasDeVida,
			})
		}
	}

	dto.RespondSuccess(c, http.StatusOK, alertas)
}
