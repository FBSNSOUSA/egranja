package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Mortalidade representa um registro de mortalidade de aves em um lote.
type Mortalidade struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID     uuid.UUID `gorm:"type:uuid;not null;index:idx_mortalidades_lote_data" json:"lote_id" validate:"required"`
	Data       time.Time `gorm:"type:date;not null;index:idx_mortalidades_lote_data" json:"data" validate:"required"`
	Quantidade int       `gorm:"type:integer;not null" json:"quantidade" validate:"required,gt=0"`
	Causa      string    `gorm:"type:varchar(50);default:'Indefinida'" json:"causa" validate:"omitempty,oneof=Indefinida Ascite 'Morte Subita' 'Problemas Locomotores' Refugo Onfalite Infecciosa Outra"`
	Observacao *string   `gorm:"type:text" json:"observacao,omitempty"`
	FotoURL    *string   `gorm:"type:text;column:foto_url" json:"foto_url,omitempty"`
	CreatedAt  time.Time `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt  time.Time `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (Mortalidade) TableName() string {
	return "mortalidades"
}

func (m *Mortalidade) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	if m.Causa == "" {
		m.Causa = "Indefinida"
	}
	return nil
}
