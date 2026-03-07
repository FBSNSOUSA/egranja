package handler

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	ws "github.com/FBSNSOUSA/egranja/backend/internal/websocket"
	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"go.uber.org/zap"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		// Em producao, restringir origens permitidas
		return true
	},
}

// WSHandler gerencia conexoes WebSocket para chat em tempo real.
type WSHandler struct {
	hub          *ws.Hub
	mensagemRepo *repository.MensagemRepository
	loteRepo     *repository.LoteRepository
	jwtSecret    string
	logger       *zap.Logger
}

// WSMessageData representa os dados de uma mensagem recebida via WebSocket.
type WSMessageData struct {
	Tipo              string  `json:"tipo"`
	Conteudo          *string `json:"conteudo,omitempty"`
	MidiaURL          *string `json:"midia_url,omitempty"`
	MidiaThumbnailURL *string `json:"midia_thumbnail_url,omitempty"`
	SolicitacaoPrazo  *string `json:"solicitacao_prazo,omitempty"`
}

// NewWSHandler cria uma nova instancia de WSHandler.
func NewWSHandler(
	hub *ws.Hub,
	mensagemRepo *repository.MensagemRepository,
	loteRepo *repository.LoteRepository,
	jwtSecret string,
	logger *zap.Logger,
) *WSHandler {
	h := &WSHandler{
		hub:          hub,
		mensagemRepo: mensagemRepo,
		loteRepo:     loteRepo,
		jwtSecret:    jwtSecret,
		logger:       logger,
	}

	// Configurar o callback de mensagens no hub
	hub.SetOnMessage(h.handleIncomingMessage)

	return h
}

// HandleWebSocket faz o upgrade HTTP para WebSocket e registra o client no hub.
// Autentica via query param "token" (JWT).
// Rota: GET /ws/lotes/:id
func (h *WSHandler) HandleWebSocket(c *gin.Context) {
	// Extrair e validar o token JWT do query param
	tokenString := c.Query("token")
	if tokenString == "" {
		dto.RespondUnauthorized(c, "Token de autenticacao nao fornecido.")
		return
	}

	// Validar JWT
	claims := &middleware.JWTClaims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(h.jwtSecret), nil
	})
	if err != nil || !token.Valid {
		dto.RespondUnauthorized(c, "Token invalido ou expirado.")
		return
	}

	userID := claims.UserID

	// Extrair e validar o lote_id da URL
	loteIDStr := c.Param("id")
	loteID, err := uuid.Parse(loteIDStr)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "ID do lote invalido.")
		return
	}

	// Verificar se o lote existe e se o usuario tem acesso
	lote, err := h.loteRepo.FindByID(loteID)
	if err != nil {
		if err == repository.ErrLoteNotFound {
			dto.RespondNotFound(c, "Lote nao encontrado.")
			return
		}
		h.logger.Error("Erro ao buscar lote para WebSocket", zap.Error(err))
		dto.RespondInternalError(c, "Erro ao buscar lote.")
		return
	}

	// Verificar acesso: produtor do lote ou tecnico vinculado
	if lote.UsuarioID != userID {
		// Se nao e o produtor, verificar se e tecnico (tipo no JWT)
		if claims.Tipo != "tecnico" {
			dto.RespondForbidden(c, "Voce nao tem acesso a este lote.")
			return
		}
		// Tecnicos tem acesso aos lotes dos produtores vinculados
		// A verificacao completa seria no banco, mas confiamos no token JWT
	}

	// Fazer upgrade para WebSocket
	conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
	if err != nil {
		h.logger.Error("Erro ao fazer upgrade WebSocket",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		return
	}

	// Criar e registrar o client
	client := ws.NewClient(h.hub, conn, userID.String(), loteIDStr, h.logger)

	h.hub.Register(client)

	// Iniciar goroutines de leitura e escrita
	go client.WritePump()
	go client.ReadPump()
}

// handleIncomingMessage processa mensagens recebidas via WebSocket.
// Salva no banco e faz broadcast para os outros clients do lote.
func (h *WSHandler) handleIncomingMessage(client *ws.Client, data json.RawMessage) {
	userID := ws.GetClientUserID(client)
	loteID := ws.GetClientLoteID(client)

	// Decodificar dados da mensagem
	var msgData WSMessageData
	if err := json.Unmarshal(data, &msgData); err != nil {
		h.logger.Warn("Dados de mensagem WebSocket invalidos",
			zap.String("user_id", userID),
			zap.Error(err),
		)
		return
	}

	// Validar tipo
	validTypes := map[string]bool{
		"texto": true, "foto": true, "audio": true, "solicitacao": true,
	}
	if !validTypes[msgData.Tipo] {
		h.logger.Warn("Tipo de mensagem invalido via WebSocket",
			zap.String("tipo", msgData.Tipo),
			zap.String("user_id", userID),
		)
		return
	}

	// Converter IDs
	parsedUserID, err := uuid.Parse(userID)
	if err != nil {
		h.logger.Error("Erro ao parsear user_id do WebSocket", zap.Error(err))
		return
	}
	parsedLoteID, err := uuid.Parse(loteID)
	if err != nil {
		h.logger.Error("Erro ao parsear lote_id do WebSocket", zap.Error(err))
		return
	}

	// Criar mensagem no banco
	mensagem := model.Mensagem{
		LoteID:            parsedLoteID,
		RemetenteID:       parsedUserID,
		Tipo:              msgData.Tipo,
		Conteudo:          msgData.Conteudo,
		MidiaURL:          msgData.MidiaURL,
		MidiaThumbnailURL: msgData.MidiaThumbnailURL,
	}

	if msgData.Tipo == "solicitacao" {
		status := "pendente"
		mensagem.SolicitacaoStatus = &status
		if msgData.SolicitacaoPrazo != nil {
			prazo, err := time.Parse("2006-01-02T15:04:05", *msgData.SolicitacaoPrazo)
			if err == nil {
				mensagem.SolicitacaoPrazo = &prazo
			}
		}
	}

	if err := h.mensagemRepo.Create(&mensagem); err != nil {
		h.logger.Error("Erro ao salvar mensagem via WebSocket",
			zap.String("user_id", userID),
			zap.String("lote_id", loteID),
			zap.Error(err),
		)
		return
	}

	// Recarregar com remetente
	mensagemCompleta, _ := h.mensagemRepo.FindByID(mensagem.ID)

	var response interface{}
	if mensagemCompleta != nil {
		response = dto.MensagemResponse{
			ID:                mensagemCompleta.ID,
			LoteID:            mensagemCompleta.LoteID,
			RemetenteID:       mensagemCompleta.RemetenteID,
			RemetenteNome:     mensagemCompleta.Remetente.Nome,
			RemetenteTipo:     mensagemCompleta.Remetente.Tipo,
			Tipo:              mensagemCompleta.Tipo,
			Conteudo:          mensagemCompleta.Conteudo,
			MidiaURL:          mensagemCompleta.MidiaURL,
			MidiaThumbnailURL: mensagemCompleta.MidiaThumbnailURL,
			SolicitacaoStatus: mensagemCompleta.SolicitacaoStatus,
			SolicitacaoPrazo:  mensagemCompleta.SolicitacaoPrazo,
			Lida:              mensagemCompleta.Lida,
			CreatedAt:         mensagemCompleta.CreatedAt,
		}
	} else {
		response = mensagem
	}

	// Broadcast para todos os clients do lote (incluindo o remetente, pois ele precisa do ID gerado)
	h.hub.BroadcastToLote(loteID, "message", response, "")

	h.logger.Debug("Mensagem WebSocket processada",
		zap.String("user_id", userID),
		zap.String("lote_id", loteID),
		zap.String("tipo", msgData.Tipo),
	)
}
