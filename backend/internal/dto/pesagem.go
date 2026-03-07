package dto

import (
	"time"

	"github.com/google/uuid"
)

// PesagemItemRequest representa um item (amostra) dentro de uma pesagem.
type PesagemItemRequest struct {
	Quantidade int     `json:"quantidade" validate:"required,gt=0"`
	Peso       float64 `json:"peso" validate:"required,gt=0"`
}

// CreatePesagemRequest representa o payload de criacao de uma pesagem.
type CreatePesagemRequest struct {
	Data  string               `json:"data" validate:"required"` // formato: YYYY-MM-DD
	Items []PesagemItemRequest `json:"items" validate:"required,min=1,dive"`
}

// PesagemItemResponse representa um item na resposta de pesagem.
type PesagemItemResponse struct {
	ID         uuid.UUID `json:"id"`
	Quantidade int       `json:"quantidade"`
	Peso       float64   `json:"peso"`
	PesoMedio  float64   `json:"peso_medio"`
}

// PesagemResponse representa a resposta de uma pesagem.
type PesagemResponse struct {
	ID              uuid.UUID             `json:"id"`
	LoteID          uuid.UUID             `json:"lote_id"`
	Data            time.Time             `json:"data"`
	QuantidadeTotal int                   `json:"quantidade_total"`
	PesoTotal       float64               `json:"peso_total"`
	PesoMedio       float64               `json:"peso_medio"`
	Items           []PesagemItemResponse `json:"items,omitempty"`
	CreatedAt       time.Time             `json:"created_at"`
}
