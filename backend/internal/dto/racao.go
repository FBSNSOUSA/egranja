package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateFeedReceiptRequest representa o payload de registro de recebimento de racao.
type CreateFeedReceiptRequest struct {
	TipoRacaoID     *uuid.UUID `json:"tipo_racao_id,omitempty"`
	QuantidadeKg    float64    `json:"quantidade_kg" validate:"required,gt=0"`
	DataRecebimento string     `json:"data_recebimento" validate:"required"` // formato: YYYY-MM-DD
	Fornecedor      *string    `json:"fornecedor,omitempty" validate:"omitempty,max=200"`
	LoteRacao       *string    `json:"lote_racao,omitempty" validate:"omitempty,max=100"`
	Origem          string     `json:"origem,omitempty" validate:"omitempty,oneof=compra remanescente_anterior sobra_final"`
}

// FeedReceiptResponse representa a resposta de um recebimento de racao.
type FeedReceiptResponse struct {
	ID              uuid.UUID  `json:"id"`
	LoteID          uuid.UUID  `json:"lote_id"`
	TipoRacaoID     *uuid.UUID `json:"tipo_racao_id,omitempty"`
	TipoRacaoNome   string     `json:"tipo_racao_nome,omitempty"`
	QuantidadeKg    float64    `json:"quantidade_kg"`
	DataRecebimento time.Time  `json:"data_recebimento"`
	Fornecedor      *string    `json:"fornecedor,omitempty"`
	LoteRacao       *string    `json:"lote_racao,omitempty"`
	Origem          string     `json:"origem"`
	CreatedAt       time.Time  `json:"created_at"`
}

// CreateFeedConsumptionRequest representa o payload de registro de consumo de racao.
type CreateFeedConsumptionRequest struct {
	Data         string  `json:"data" validate:"required"` // formato: YYYY-MM-DD
	QuantidadeKg float64 `json:"quantidade_kg" validate:"required,gt=0"`
}

// FeedConsumptionResponse representa a resposta de um consumo de racao.
type FeedConsumptionResponse struct {
	ID           uuid.UUID `json:"id"`
	LoteID       uuid.UUID `json:"lote_id"`
	Data         time.Time `json:"data"`
	QuantidadeKg float64   `json:"quantidade_kg"`
	CreatedAt    time.Time `json:"created_at"`
}

// SaldoRacaoResponse representa o saldo atual de racao de um lote.
type SaldoRacaoResponse struct {
	RecebidoTotalKg    float64  `json:"recebido_total_kg"`
	ConsumoTotalKg     float64  `json:"consumo_total_kg"`
	SaldoKg            float64  `json:"saldo_kg"`
	DiasEstoqueRestante *float64 `json:"dias_estoque_restante,omitempty"`
}
