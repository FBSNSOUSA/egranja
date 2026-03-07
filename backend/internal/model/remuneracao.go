package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Remuneracao representa o registro de remuneracao da integradora por lote.
type Remuneracao struct {
	ID             uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID         uuid.UUID  `gorm:"type:uuid;not null" json:"lote_id" validate:"required"`
	Valor          float64    `gorm:"type:numeric(12,2);not null" json:"valor" validate:"required"`
	Tipo           *string    `gorm:"type:varchar(30)" json:"tipo,omitempty" validate:"omitempty,oneof=por_kg por_ave por_iep outro"`
	DataPagamento  *time.Time `gorm:"type:date" json:"data_pagamento,omitempty"`
	Observacao     *string    `gorm:"type:text" json:"observacao,omitempty"`
	CreatedAt      time.Time  `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (Remuneracao) TableName() string {
	return "remuneracoes"
}

func (r *Remuneracao) BeforeCreate(tx *gorm.DB) error {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	return nil
}
