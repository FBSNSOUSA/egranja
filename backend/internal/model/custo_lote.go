package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// CustoLote representa um custo de producao associado a um lote.
type CustoLote struct {
	ID        uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID    uuid.UUID  `gorm:"type:uuid;not null;index:idx_custos_lote" json:"lote_id" validate:"required"`
	Categoria string     `gorm:"type:varchar(50);not null" json:"categoria" validate:"required,oneof=mao_de_obra energia aquecimento cama manutencao depreciacao agua outros"`
	Descricao *string    `gorm:"type:varchar(200)" json:"descricao,omitempty" validate:"omitempty,max=200"`
	Valor     float64    `gorm:"type:numeric(12,2);not null" json:"valor" validate:"required"`
	Data      *time.Time `gorm:"type:date" json:"data,omitempty"`
	CreatedAt time.Time  `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (CustoLote) TableName() string {
	return "custos_lote"
}

func (c *CustoLote) BeforeCreate(tx *gorm.DB) error {
	if c.ID == uuid.Nil {
		c.ID = uuid.New()
	}
	return nil
}
