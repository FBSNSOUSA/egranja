package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// WaterConsumption representa um registro de consumo de agua de um lote.
type WaterConsumption struct {
	ID               uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID           uuid.UUID `gorm:"type:uuid;not null;index:idx_water_consumptions_lote" json:"lote_id" validate:"required"`
	Data             time.Time `gorm:"type:date;not null" json:"data" validate:"required"`
	QuantidadeLitros float64   `gorm:"type:numeric(12,3);not null" json:"quantidade_litros" validate:"required,gt=0"`
	CreatedAt        time.Time `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt        time.Time `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (WaterConsumption) TableName() string {
	return "water_consumptions"
}

func (w *WaterConsumption) BeforeCreate(tx *gorm.DB) error {
	if w.ID == uuid.Nil {
		w.ID = uuid.New()
	}
	return nil
}
