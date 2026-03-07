package dto

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// BlockchainCadeiaResponse representa a cadeia completa de rastreabilidade do lote (avancada).
type BlockchainCadeiaResponse struct {
	LoteID     uuid.UUID                        `json:"lote_id"`
	Integra    bool                             `json:"integra"`
	TotalElos  int                              `json:"total_elos"`
	Cadeia     []BlockchainItemResponse         `json:"cadeia"`
}

// BlockchainItemResponse representa um elo da cadeia de rastreabilidade.
type BlockchainItemResponse struct {
	ID           uuid.UUID       `json:"id"`
	Evento       string          `json:"evento"`
	Dados        json.RawMessage `json:"dados"`
	HashAtual    string          `json:"hash_atual"`
	HashAnterior *string         `json:"hash_anterior,omitempty"`
	CreatedAt    time.Time       `json:"created_at"`
}

// VerificacaoIntegridadeResponse representa o resultado da verificacao de integridade.
type VerificacaoIntegridadeResponse struct {
	LoteID    uuid.UUID `json:"lote_id"`
	Integra   bool      `json:"integra"`
	TotalElos int       `json:"total_elos"`
	Erros     []string  `json:"erros"`
}

// CertificadoRastreabilidadeResponse representa os dados do certificado de rastreabilidade.
type CertificadoRastreabilidadeResponse struct {
	LoteID          uuid.UUID      `json:"lote_id"`
	Integra         bool           `json:"integra"`
	TotalEventos    int            `json:"total_eventos"`
	PrimeiroEvento  time.Time      `json:"primeiro_evento"`
	UltimoEvento    time.Time      `json:"ultimo_evento"`
	HashRaiz        string         `json:"hash_raiz"`
	HashFinal       string         `json:"hash_final"`
	QRCodeData      string         `json:"qr_code_data"`
	Resumo          map[string]int `json:"resumo"` // contagem por tipo de evento
}
