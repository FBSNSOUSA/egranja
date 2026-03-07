package handler

import (
	"encoding/json"
	"errors"
	"fmt"
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// BlockchainHandler gerencia os endpoints de rastreabilidade blockchain.
type BlockchainHandler struct {
	blockchainService *service.BlockchainService
	loteRepo          *repository.LoteRepository
	logger            *zap.Logger
}

// NewBlockchainHandler cria uma nova instancia de BlockchainHandler.
func NewBlockchainHandler(blockchainService *service.BlockchainService, loteRepo *repository.LoteRepository, logger *zap.Logger) *BlockchainHandler {
	return &BlockchainHandler{
		blockchainService: blockchainService,
		loteRepo:          loteRepo,
		logger:            logger,
	}
}

// GetRastreabilidade godoc
// @Summary      Cadeia de rastreabilidade completa
// @Description  Retorna a cadeia completa de rastreabilidade do lote com detalhes de blockchain
// @Tags         blockchain
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=dto.BlockchainCadeiaResponse}
// @Failure      404 {object} dto.ErrorResponse
// @Router       /lotes/{id}/rastreabilidade/completa [get]
func (h *BlockchainHandler) GetRastreabilidade(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	loteID, err := h.getLoteIDAutenticado(c, userID)
	if err != nil {
		return
	}

	chains, integra, err := h.blockchainService.GetCadeia(loteID)
	if err != nil {
		h.logger.Error("Erro ao buscar cadeia de rastreabilidade", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar rastreabilidade.")
		return
	}

	response := dto.BlockchainCadeiaResponse{
		LoteID:    loteID,
		Integra:   integra,
		TotalElos: len(chains),
		Cadeia:    make([]dto.BlockchainItemResponse, 0, len(chains)),
	}

	for _, chain := range chains {
		response.Cadeia = append(response.Cadeia, dto.BlockchainItemResponse{
			ID:           chain.ID,
			Evento:       chain.Evento,
			Dados:        chain.Dados,
			HashAtual:    chain.HashAtual,
			HashAnterior: chain.HashAnterior,
			CreatedAt:    chain.CreatedAt,
		})
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// Verificar godoc
// @Summary      Verificar integridade da cadeia
// @Description  Verifica a integridade da cadeia de rastreabilidade do lote
// @Tags         blockchain
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=dto.VerificacaoIntegridadeResponse}
// @Router       /lotes/{id}/rastreabilidade/verificar [get]
func (h *BlockchainHandler) Verificar(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	loteID, err := h.getLoteIDAutenticado(c, userID)
	if err != nil {
		return
	}

	chains, integra, err := h.blockchainService.GetCadeia(loteID)
	if err != nil {
		h.logger.Error("Erro ao verificar cadeia", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao verificar integridade.")
		return
	}

	errosIntegridade := make([]string, 0)

	// Verificacao detalhada de encadeamento
	for i := 1; i < len(chains); i++ {
		if chains[i].HashAnterior == nil {
			errosIntegridade = append(errosIntegridade,
				fmt.Sprintf("Bloco %d (%s): hash anterior ausente", i, chains[i].Evento))
		} else if *chains[i].HashAnterior != chains[i-1].HashAtual {
			errosIntegridade = append(errosIntegridade,
				fmt.Sprintf("Bloco %d (%s): hash anterior nao corresponde ao bloco %d", i, chains[i].Evento, i-1))
		}
	}

	// Verificar hash de cada bloco
	for i, chain := range chains {
		hashRecalculado := chain.CalculaHash()
		if hashRecalculado != chain.HashAtual {
			errosIntegridade = append(errosIntegridade,
				fmt.Sprintf("Bloco %d (%s): hash recalculado nao corresponde (dados podem ter sido alterados)", i, chain.Evento))
		}
	}

	response := dto.VerificacaoIntegridadeResponse{
		LoteID:    loteID,
		Integra:   integra && len(errosIntegridade) == 0,
		TotalElos: len(chains),
		Erros:     errosIntegridade,
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// Certificado godoc
// @Summary      Certificado de rastreabilidade
// @Description  Gera dados do certificado de rastreabilidade do lote
// @Tags         blockchain
// @Produce      json
// @Security     BearerAuth
// @Param        id path string true "ID do lote"
// @Success      200 {object} dto.SuccessResponse{data=dto.CertificadoRastreabilidadeResponse}
// @Router       /lotes/{id}/rastreabilidade/certificado [get]
func (h *BlockchainHandler) Certificado(c *gin.Context) {
	userID, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	loteID, err := h.getLoteIDAutenticado(c, userID)
	if err != nil {
		return
	}

	chains, integra, err := h.blockchainService.GetCadeia(loteID)
	if err != nil {
		h.logger.Error("Erro ao gerar certificado", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao gerar certificado.")
		return
	}

	if len(chains) == 0 {
		dto.RespondNotFound(c, "Nenhum evento de rastreabilidade registrado para este lote.")
		return
	}

	// Contagem por tipo de evento
	resumo := make(map[string]int)
	for _, chain := range chains {
		resumo[chain.Evento]++
	}

	// QR code data: JSON com info essencial
	qrData := map[string]interface{}{
		"lote_id":    loteID,
		"integra":    integra,
		"total":      len(chains),
		"hash_final": chains[len(chains)-1].HashAtual,
	}
	qrJSON, _ := json.Marshal(qrData)

	response := dto.CertificadoRastreabilidadeResponse{
		LoteID:         loteID,
		Integra:        integra,
		TotalEventos:   len(chains),
		PrimeiroEvento: chains[0].CreatedAt,
		UltimoEvento:   chains[len(chains)-1].CreatedAt,
		HashRaiz:       chains[0].HashAtual,
		HashFinal:      chains[len(chains)-1].HashAtual,
		QRCodeData:     string(qrJSON),
		Resumo:         resumo,
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

// getLoteIDAutenticado busca um lote pelo ID do path e verifica pertence ao usuario.
func (h *BlockchainHandler) getLoteIDAutenticado(c *gin.Context, userID uuid.UUID) (uuid.UUID, error) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID invalido.")
		return uuid.Nil, err
	}

	lote, err := h.loteRepo.FindByID(id)
	if err != nil {
		if errors.Is(err, repository.ErrLoteNotFound) {
			dto.RespondNotFound(c, "Lote nao encontrado.")
			return uuid.Nil, err
		}
		h.logger.Error("Erro ao buscar lote", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar lote.")
		return uuid.Nil, err
	}

	if lote.UsuarioID != userID {
		dto.RespondForbidden(c, "Voce nao tem acesso a este lote.")
		return uuid.Nil, errors.New("acesso negado")
	}

	return lote.ID, nil
}
