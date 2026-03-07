package websocket

import (
	"encoding/json"
	"sync"

	"go.uber.org/zap"
)

// MessageHandler e o tipo do callback chamado quando um client envia uma mensagem.
type MessageHandler func(client *Client, data json.RawMessage)

// Hub central de WebSocket que gerencia conexoes por lote.
// Cada lote possui seu proprio conjunto de clients conectados.
type Hub struct {
	// clients armazena os clients conectados, agrupados por lote_id.
	// Estrutura: map[loteID]map[*Client]bool
	clients map[string]map[*Client]bool

	// register canal para registrar novos clients.
	register chan *Client

	// unregister canal para remover clients desconectados.
	unregister chan *Client

	// broadcast canal para enviar mensagens para todos os clients de um lote.
	broadcast chan *BroadcastMessage

	// onMessage callback para processar mensagens recebidas dos clients.
	onMessage MessageHandler

	// mu protege acesso concorrente ao mapa de clients.
	mu sync.RWMutex

	logger *zap.Logger
}

// BroadcastMessage representa uma mensagem a ser enviada para todos os clients de um lote.
type BroadcastMessage struct {
	LoteID  string          `json:"-"`
	Type    string          `json:"type"`
	Data    json.RawMessage `json:"data"`
	SenderID string         `json:"-"` // ID do remetente (para nao enviar de volta)
}

// WSMessage representa a estrutura padrao de uma mensagem WebSocket.
type WSMessage struct {
	Type string          `json:"type"`
	Data json.RawMessage `json:"data"`
}

// NewHub cria uma nova instancia do Hub.
func NewHub(logger *zap.Logger) *Hub {
	return &Hub{
		clients:    make(map[string]map[*Client]bool),
		register:   make(chan *Client),
		unregister: make(chan *Client),
		broadcast:  make(chan *BroadcastMessage, 256),
		logger:     logger,
	}
}

// Run inicia o loop principal do hub em uma goroutine.
// Deve ser chamado com go hub.Run() antes de aceitar conexoes.
func (h *Hub) Run() {
	for {
		select {
		case client := <-h.register:
			h.mu.Lock()
			if _, ok := h.clients[client.loteID]; !ok {
				h.clients[client.loteID] = make(map[*Client]bool)
			}
			h.clients[client.loteID][client] = true
			h.mu.Unlock()

			h.logger.Info("Client WebSocket registrado",
				zap.String("user_id", client.userID),
				zap.String("lote_id", client.loteID),
				zap.Int("clients_no_lote", h.ClientCount(client.loteID)),
			)

		case client := <-h.unregister:
			h.mu.Lock()
			if clients, ok := h.clients[client.loteID]; ok {
				if _, exists := clients[client]; exists {
					delete(clients, client)
					close(client.send)

					// Limpar mapa do lote se nao houver mais clients
					if len(clients) == 0 {
						delete(h.clients, client.loteID)
					}
				}
			}
			h.mu.Unlock()

			h.logger.Info("Client WebSocket desregistrado",
				zap.String("user_id", client.userID),
				zap.String("lote_id", client.loteID),
			)

		case message := <-h.broadcast:
			h.mu.RLock()
			clients, ok := h.clients[message.LoteID]
			h.mu.RUnlock()

			if !ok {
				continue
			}

			// Serializar a mensagem uma vez para todos os clients
			payload, err := json.Marshal(WSMessage{
				Type: message.Type,
				Data: message.Data,
			})
			if err != nil {
				h.logger.Error("Erro ao serializar mensagem WS", zap.Error(err))
				continue
			}

			h.mu.RLock()
			for client := range clients {
				// Nao enviar de volta para o remetente
				if client.userID == message.SenderID {
					continue
				}
				select {
				case client.send <- payload:
				default:
					// Buffer cheio, remover client
					go func(c *Client) {
						h.unregister <- c
					}(client)
				}
			}
			h.mu.RUnlock()
		}
	}
}

// BroadcastToLote envia uma mensagem para todos os clients conectados a um lote.
func (h *Hub) BroadcastToLote(loteID string, msgType string, data interface{}, senderID string) {
	jsonData, err := json.Marshal(data)
	if err != nil {
		h.logger.Error("Erro ao serializar dados para broadcast",
			zap.String("lote_id", loteID),
			zap.Error(err),
		)
		return
	}

	h.broadcast <- &BroadcastMessage{
		LoteID:   loteID,
		Type:     msgType,
		Data:     jsonData,
		SenderID: senderID,
	}
}

// Register registra um novo client no hub.
func (h *Hub) Register(client *Client) {
	h.register <- client
}

// SetOnMessage define o callback para processar mensagens recebidas.
func (h *Hub) SetOnMessage(handler MessageHandler) {
	h.onMessage = handler
}

// GetClientUserID retorna o userID de um client.
func GetClientUserID(c *Client) string {
	return c.userID
}

// GetClientLoteID retorna o loteID de um client.
func GetClientLoteID(c *Client) string {
	return c.loteID
}

// ClientCount retorna o numero de clients conectados a um lote.
func (h *Hub) ClientCount(loteID string) int {
	h.mu.RLock()
	defer h.mu.RUnlock()

	if clients, ok := h.clients[loteID]; ok {
		return len(clients)
	}
	return 0
}

// TotalClients retorna o numero total de clients conectados.
func (h *Hub) TotalClients() int {
	h.mu.RLock()
	defer h.mu.RUnlock()

	total := 0
	for _, clients := range h.clients {
		total += len(clients)
	}
	return total
}
