package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// FeedConsumption representa um registro de consumo de racao de um lote.
type FeedConsumption struct {
	ID           uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID       uuid.UUID `gorm:"type:uuid;not null;index:idx_feed_consumptions_lote" json:"lote_id" validate:"required"`
	Data         time.Time `gorm:"type:date;not null" json:"data" validate:"required"`
	QuantidadeKg float64   `gorm:"type:numeric(12,3);not null" json:"quantidade_kg" validate:"required,gt=0"`
	CreatedAt    time.Time `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt    time.Time `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (FeedConsumption) TableName() string {
	return "feed_consumptions"
}

func (f *FeedConsumption) BeforeCreate(tx *gorm.DB) error {
	if f.ID == uuid.Nil {
		f.ID = uuid.New()
	}
	return nil
}
