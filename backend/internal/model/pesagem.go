package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Pesagem representa uma sessao de pesagem de um lote.
type Pesagem struct {
	ID              uuid.UUID     `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID          uuid.UUID     `gorm:"type:uuid;not null;index:idx_pesagens_lote_data" json:"lote_id" validate:"required"`
	Data            time.Time     `gorm:"type:date;not null;index:idx_pesagens_lote_data" json:"data" validate:"required"`
	QuantidadeTotal int           `gorm:"type:integer;not null" json:"quantidade_total" validate:"required,gt=0"`
	PesoTotal       float64       `gorm:"type:numeric(12,3);not null" json:"peso_total" validate:"required,gt=0"`
	PesoMedio       float64       `gorm:"type:numeric(12,3);not null" json:"peso_medio"`
	CreatedAt       time.Time     `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt       time.Time     `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Lote  Lote          `gorm:"foreignKey:LoteID" json:"-"`
	Items []PesagemItem `gorm:"foreignKey:PesagemID" json:"items,omitempty"`
}

func (Pesagem) TableName() string {
	return "pesagens"
}

func (p *Pesagem) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return nil
}

// CalculaPesoMedio calcula o peso medio a partir do peso total e quantidade.
func (p *Pesagem) CalculaPesoMedio() {
	if p.QuantidadeTotal > 0 {
		p.PesoMedio = p.PesoTotal / float64(p.QuantidadeTotal)
	}
}
