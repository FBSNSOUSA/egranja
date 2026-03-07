package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateMensagemRequest representa o payload de envio de mensagem.
type CreateMensagemRequest struct {
	Tipo              string     `json:"tipo" validate:"required,oneof=texto foto audio solicitacao visita"`
	Conteudo          *string    `json:"conteudo,omitempty"`
	MidiaURL          *string    `json:"midia_url,omitempty"`
	MidiaThumbnailURL *string    `json:"midia_thumbnail_url,omitempty"`
	SolicitacaoPrazo  *string    `json:"solicitacao_prazo,omitempty"` // formato: YYYY-MM-DDTHH:MM:SS
}

// MensagemResponse representa a resposta de uma mensagem.
type MensagemResponse struct {
	ID                uuid.UUID  `json:"id"`
	LoteID            uuid.UUID  `json:"lote_id"`
	RemetenteID       uuid.UUID  `json:"remetente_id"`
	RemetenteNome     string     `json:"remetente_nome"`
	RemetenteTipo     string     `json:"remetente_tipo"`
	Tipo              string     `json:"tipo"`
	Conteudo          *string    `json:"conteudo,omitempty"`
	MidiaURL          *string    `json:"midia_url,omitempty"`
	MidiaThumbnailURL *string    `json:"midia_thumbnail_url,omitempty"`
	SolicitacaoStatus *string    `json:"solicitacao_status,omitempty"`
	SolicitacaoPrazo  *time.Time `json:"solicitacao_prazo,omitempty"`
	Lida              bool       `json:"lida"`
	CreatedAt         time.Time  `json:"created_at"`
}

// VisitaRequest representa o payload de registro de visita tecnica.
type VisitaRequest struct {
	DataHora    string   `json:"data_hora" validate:"required"` // formato: YYYY-MM-DDTHH:MM:SS
	Observacoes *string  `json:"observacoes,omitempty"`
	FotosURLs   []string `json:"fotos_urls,omitempty"`
}

// ContadorMensagensResponse representa a contagem de mensagens nao lidas.
type ContadorMensagensResponse struct {
	NaoLidas int64 `json:"nao_lidas"`
}
