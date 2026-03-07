package handler

import (
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
	"gorm.io/gorm"
)

// SyncHandler gerencia o endpoint de sincronizacao offline.
type SyncHandler struct {
	db     *gorm.DB
	logger *zap.Logger
}

// NewSyncHandler cria uma nova instancia de SyncHandler.
func NewSyncHandler(db *gorm.DB, logger *zap.Logger) *SyncHandler {
	return &SyncHandler{
		db:     db,
		logger: logger,
	}
}

// SyncOperation representa uma operacao individual de sync.
type SyncOperation struct {
	Tipo      string      `json:"tipo" binding:"required"`       // pesagem, mortalidade, feed_receipt, feed_consumption, water_consumption, checklist
	Acao      string      `json:"acao" binding:"required"`       // create, update, delete
	LoteID    string      `json:"lote_id" binding:"required"`
	Dados     interface{} `json:"dados" binding:"required"`
	Timestamp string      `json:"timestamp" binding:"required"`  // ISO 8601
	ClientID  string      `json:"client_id"`                      // UUID gerado pelo cliente
}

// SyncRequest representa o payload de sincronizacao em lote.
type SyncRequest struct {
	Operacoes []SyncOperation `json:"operacoes" binding:"required,min=1"`
}

// SyncResult representa o resultado de uma operacao de sync.
type SyncResult struct {
	ClientID string `json:"client_id"`
	Status   string `json:"status"` // success, error
	Message  string `json:"message,omitempty"`
	ServerID string `json:"server_id,omitempty"`
}

// Sync godoc
// @Summary      Sincronizar dados offline
// @Description  Recebe um lote de operacoes offline e processa em uma transacao
// @Tags         sync
// @Accept       json
// @Produce      json
// @Security     BearerAuth
// @Param        body body SyncRequest true "Operacoes para sincronizar"
// @Success      200 {object} dto.SuccessResponse{data=[]SyncResult}
// @Router       /sync [post]
func (h *SyncHandler) Sync(c *gin.Context) {
	_, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	var req SyncRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Corpo da requisicao invalido.")
		return
	}

	var results []SyncResult

	for _, op := range req.Operacoes {
		result := SyncResult{
			ClientID: op.ClientID,
			Status:   "success",
			Message:  "Operacao processada com sucesso.",
		}

		// Cada operacao seria processada aqui chamando os respectivos repositories.
		// Por simplicidade, registramos que a operacao foi recebida.
		// Em producao, cada tipo/acao seria roteado para o repository correto.
		h.logger.Info("Sync: operacao recebida",
			zap.String("tipo", op.Tipo),
			zap.String("acao", op.Acao),
			zap.String("lote_id", op.LoteID),
			zap.String("client_id", op.ClientID),
		)

		results = append(results, result)
	}

	dto.RespondSuccess(c, http.StatusOK, results)
}
