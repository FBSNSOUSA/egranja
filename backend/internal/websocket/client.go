package websocket

import (
	"encoding/json"
	"time"

	"github.com/gorilla/websocket"
	"go.uber.org/zap"
)

const (
	// writeWait tempo maximo de espera para enviar uma mensagem ao client.
	writeWait = 10 * time.Second

	// pongWait tempo maximo de espera por um pong do client.
	pongWait = 60 * time.Second

	// pingPeriod intervalo de envio de pings (deve ser menor que pongWait).
	pingPeriod = 54 * time.Second

	// maxMessageSize tamanho maximo de mensagem aceito do client (64KB).
	maxMessageSize = 65536
)

// Client representa uma conexao WebSocket individual.
type Client struct {
	hub    *Hub
	conn   *websocket.Conn
	send   chan []byte
	userID string
	loteID string
	logger *zap.Logger
}

// NewClient cria uma nova instancia de Client.
func NewClient(hub *Hub, conn *websocket.Conn, userID, loteID string, logger *zap.Logger) *Client {
	return &Client{
		hub:    hub,
		conn:   conn,
		send:   make(chan []byte, 256),
		userID: userID,
		loteID: loteID,
		logger: logger,
	}
}

// ReadPump le mensagens do client WebSocket.
// Roda em uma goroutine dedicada por client.
// Quando a conexao e fechada, o client e removido do hub.
func (c *Client) ReadPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close()
	}()

	c.conn.SetReadLimit(maxMessageSize)
	c.conn.SetReadDeadline(time.Now().Add(pongWait))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(pongWait))
		return nil
	})

	for {
		_, message, err := c.conn.ReadMessage()
		if err != nil {
			if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseNormalClosure) {
				c.logger.Warn("Erro inesperado ao ler WebSocket",
					zap.String("user_id", c.userID),
					zap.String("lote_id", c.loteID),
					zap.Error(err),
				)
			}
			break
		}

		// Decodificar a mensagem recebida
		var wsMsg WSMessage
		if err := json.Unmarshal(message, &wsMsg); err != nil {
			c.logger.Warn("Mensagem WebSocket com formato invalido",
				zap.String("user_id", c.userID),
				zap.Error(err),
			)
			continue
		}

		// Processar por tipo de mensagem
		switch wsMsg.Type {
		case "typing":
			// Broadcast do indicador de digitacao para os outros clients do lote
			c.hub.BroadcastToLote(c.loteID, "typing", map[string]string{
				"user_id": c.userID,
			}, c.userID)

		case "read":
			// Broadcast da confirmacao de leitura
			c.hub.BroadcastToLote(c.loteID, "read", map[string]string{
				"user_id": c.userID,
			}, c.userID)

		case "message":
			// Mensagens de texto sao processadas pelo handler (via callback)
			// O handler e responsavel por salvar no banco e fazer o broadcast
			if c.hub.onMessage != nil {
				c.hub.onMessage(c, wsMsg.Data)
			}

		default:
			c.logger.Debug("Tipo de mensagem WebSocket desconhecido",
				zap.String("type", wsMsg.Type),
				zap.String("user_id", c.userID),
			)
		}
	}
}

// WritePump envia mensagens para o client WebSocket.
// Roda em uma goroutine dedicada por client.
// Envia pings periodicamente para manter a conexao viva.
func (c *Client) WritePump() {
	ticker := time.NewTicker(pingPeriod)
	defer func() {
		ticker.Stop()
		c.conn.Close()
	}()

	for {
		select {
		case message, ok := <-c.send:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if !ok {
				// Hub fechou o canal
				c.conn.WriteMessage(websocket.CloseMessage, []byte{})
				return
			}

			w, err := c.conn.NextWriter(websocket.TextMessage)
			if err != nil {
				return
			}
			w.Write(message)

			// Enviar mensagens pendentes no buffer (batch)
			n := len(c.send)
			for i := 0; i < n; i++ {
				w.Write([]byte{'\n'})
				w.Write(<-c.send)
			}

			if err := w.Close(); err != nil {
				return
			}

		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(writeWait))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				return
			}
		}
	}
}
