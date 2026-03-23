package model

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ChecklistItem representa um item individual do checklist diario.
type ChecklistItem struct {
	Descricao  string  `json:"descricao"`
	Completado bool    `json:"completado"`
	Observacao *string `json:"observacao,omitempty"`
	FotoURL    *string `json:"foto_url,omitempty"`
}

// Checklist representa o checklist diario de manejo de um lote.
type Checklist struct {
	ID         uuid.UUID       `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID     uuid.UUID       `gorm:"type:uuid;not null;uniqueIndex:uq_checklist_lote_data" json:"lote_id" validate:"required"`
	Data       time.Time       `gorm:"type:date;not null;uniqueIndex:uq_checklist_lote_data" json:"data" validate:"required"`
	Itens      json.RawMessage `gorm:"type:jsonb;not null;default:'[]'" json:"itens"`
	Completado bool            `gorm:"not null;default:false" json:"completado"`
	CreatedAt  time.Time       `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt  time.Time       `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (Checklist) TableName() string {
	return "checklists"
}

func (c *Checklist) BeforeCreate(tx *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	return nil
}

// GetItens deserializa os itens do checklist.
func (c *Checklist) GetItens() ([]ChecklistItem, error) {
	var items []ChecklistItem
	if err := json.Unmarshal(c.Itens, &items); err != nil {
		return nil, err
	}
	return items, nil
}

// SetItens serializa os itens do checklist.
func (c *Checklist) SetItens(items []ChecklistItem) error {
	data, err := json.Marshal(items)
	if err != nil {
		return err
	}
	c.Itens = data
	return nil
}

// PorcentagemConclusao calcula a porcentagem de itens completados.
func (c *Checklist) PorcentagemConclusao() float64 {
	items, err := c.GetItens()
	if err != nil || len(items) == 0 {
		return 0
	}
	completados := 0
	for _, item := range items {
		if item.Completado {
			completados++
		}
	}
	return float64(completados) / float64(len(items)) * 100
}
