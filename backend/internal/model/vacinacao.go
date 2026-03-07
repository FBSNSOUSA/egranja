package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Vacinacao representa um registro de vacinacao de um lote.
type Vacinacao struct {
	ID               uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID           uuid.UUID `gorm:"type:uuid;not null;index:idx_vacinacoes_lote" json:"lote_id" validate:"required"`
	Data             time.Time `gorm:"type:date;not null" json:"data" validate:"required"`
	Vacina           string    `gorm:"type:varchar(200);not null" json:"vacina" validate:"required,max=200"`
	LoteProduto      *string   `gorm:"type:varchar(100)" json:"lote_produto,omitempty" validate:"omitempty,max=100"`
	ViaAdministracao *string   `gorm:"type:varchar(50)" json:"via_administracao,omitempty" validate:"omitempty,max=50"`
	Responsavel      *string   `gorm:"type:varchar(200)" json:"responsavel,omitempty" validate:"omitempty,max=200"`
	Observacao       *string   `gorm:"type:text" json:"observacao,omitempty"`
	CreatedAt        time.Time `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (Vacinacao) TableName() string {
	return "vacinacoes"
}

func (v *Vacinacao) BeforeCreate(tx *gorm.DB) error {
	if v.ID == uuid.Nil {
		v.ID = uuid.New()
	}
	return nil
}
