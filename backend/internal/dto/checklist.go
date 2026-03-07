package dto

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

// ChecklistItemDTO representa um item do checklist.
type ChecklistItemDTO struct {
	Descricao  string `json:"descricao" validate:"required"`
	Completado bool   `json:"completado"`
}

// CreateChecklistRequest representa o payload de criacao/atualizacao de um checklist.
type CreateChecklistRequest struct {
	Data  string              `json:"data" validate:"required"` // formato: YYYY-MM-DD
	Itens []ChecklistItemDTO  `json:"itens" validate:"required,min=1,dive"`
}

// UpdateChecklistRequest representa o payload de atualizacao dos itens de um checklist.
type UpdateChecklistRequest struct {
	Itens []ChecklistItemDTO `json:"itens" validate:"required,min=1,dive"`
}

// ChecklistResponse representa a resposta de um checklist.
type ChecklistResponse struct {
	ID                   uuid.UUID       `json:"id"`
	LoteID               uuid.UUID       `json:"lote_id"`
	Data                 time.Time       `json:"data"`
	Itens                json.RawMessage `json:"itens"`
	Completado           bool            `json:"completado"`
	PorcentagemConclusao float64         `json:"porcentagem_conclusao"`
	CreatedAt            time.Time       `json:"created_at"`
	UpdatedAt            time.Time       `json:"updated_at"`
}
