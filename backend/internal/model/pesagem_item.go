package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// PesagemItem representa uma amostra individual dentro de uma pesagem.
type PesagemItem struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	PesagemID  uuid.UUID `gorm:"type:uuid;not null;index:idx_pesagem_items_pesagem" json:"pesagem_id" validate:"required"`
	Quantidade int       `gorm:"type:integer;not null" json:"quantidade" validate:"required,gt=0"`
	Peso       float64   `gorm:"type:numeric(12,3);not null" json:"peso" validate:"required,gt=0"`
	PesoMedio  float64   `gorm:"type:numeric(12,3);not null" json:"peso_medio"`
	CreatedAt  time.Time `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Pesagem Pesagem `gorm:"foreignKey:PesagemID" json:"-"`
}

func (PesagemItem) TableName() string {
	return "pesagem_items"
}

func (pi *PesagemItem) BeforeCreate(tx *gorm.DB) error {
	if pi.ID == uuid.Nil {
		pi.ID = uuid.New()
	}
	if pi.Quantidade > 0 {
		pi.PesoMedio = pi.Peso / float64(pi.Quantidade)
	}
	return nil
}
