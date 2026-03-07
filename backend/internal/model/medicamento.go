package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Medicamento representa um registro de uso de medicamento em um lote.
type Medicamento struct {
	ID                  uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID              uuid.UUID  `gorm:"type:uuid;not null;index:idx_medicamentos_lote" json:"lote_id" validate:"required"`
	DataInicio          time.Time  `gorm:"type:date;not null" json:"data_inicio" validate:"required"`
	DataFim             *time.Time `gorm:"type:date" json:"data_fim,omitempty"`
	Medicamento         string     `gorm:"type:varchar(200);not null;column:medicamento" json:"medicamento" validate:"required,max=200"`
	Dosagem             *string    `gorm:"type:varchar(100)" json:"dosagem,omitempty" validate:"omitempty,max=100"`
	Via                 *string    `gorm:"type:varchar(50)" json:"via,omitempty" validate:"omitempty,max=50"`
	PeriodoCarenciaDias *int       `gorm:"type:integer;default:0" json:"periodo_carencia_dias,omitempty" validate:"omitempty,gte=0"`
	Responsavel         *string    `gorm:"type:varchar(200)" json:"responsavel,omitempty" validate:"omitempty,max=200"`
	Observacao          *string    `gorm:"type:text" json:"observacao,omitempty"`
	CreatedAt           time.Time  `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (Medicamento) TableName() string {
	return "medicamentos"
}

func (m *Medicamento) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	return nil
}
