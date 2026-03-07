package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// RegistroAmbiental representa um registro de temperatura e umidade (manual ou IoT).
type RegistroAmbiental struct {
	ID            uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID        uuid.UUID `gorm:"type:uuid;not null;index:idx_reg_amb_lote" json:"lote_id" validate:"required"`
	Data          time.Time `gorm:"type:date;not null;index:idx_reg_amb_lote" json:"data" validate:"required"`
	TemperaturaMin *float64 `gorm:"type:numeric(5,2)" json:"temperatura_min,omitempty"`
	TemperaturaMax *float64 `gorm:"type:numeric(5,2)" json:"temperatura_max,omitempty"`
	UmidadeMin    *float64  `gorm:"type:numeric(5,2)" json:"umidade_min,omitempty"`
	UmidadeMax    *float64  `gorm:"type:numeric(5,2)" json:"umidade_max,omitempty"`
	Origem        string    `gorm:"type:varchar(20);not null;default:'manual'" json:"origem" validate:"oneof=manual iot"`
	CreatedAt     time.Time `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (RegistroAmbiental) TableName() string {
	return "registros_ambientais"
}

func (r *RegistroAmbiental) BeforeCreate(tx *gorm.DB) error {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	if r.Origem == "" {
		r.Origem = "manual"
	}
	return nil
}
