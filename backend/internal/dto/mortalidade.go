package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateMortalidadeRequest representa o payload de criacao de um registro de mortalidade.
type CreateMortalidadeRequest struct {
	Data       string  `json:"data" validate:"required"` // formato: YYYY-MM-DD
	Quantidade int     `json:"quantidade" validate:"required,gt=0"`
	Causa      string  `json:"causa,omitempty" validate:"omitempty,oneof=Indefinida Ascite 'Morte Subita' 'Problemas Locomotores' Refugo Onfalite Infecciosa Outra"`
	Observacao *string `json:"observacao,omitempty"`
	FotoURL    *string `json:"foto_url,omitempty"`
}

// MortalidadeResponse representa a resposta de um registro de mortalidade.
type MortalidadeResponse struct {
	ID         uuid.UUID  `json:"id"`
	LoteID     uuid.UUID  `json:"lote_id"`
	Data       time.Time  `json:"data"`
	Quantidade int        `json:"quantidade"`
	Causa      string     `json:"causa"`
	Observacao *string    `json:"observacao,omitempty"`
	FotoURL    *string    `json:"foto_url,omitempty"`
	CreatedAt  time.Time  `json:"created_at"`
}

// MortalidadeResumoResponse representa o resumo de mortalidade de um lote.
type MortalidadeResumoResponse struct {
	MortesHoje        int     `json:"mortes_hoje"`
	MortesUltimos7Dias int    `json:"mortes_ultimos_7_dias"`
	MortalidadeTotal  int     `json:"mortalidade_total"`
	PercentualTotal   float64 `json:"percentual_total"`
}
