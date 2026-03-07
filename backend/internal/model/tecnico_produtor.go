package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// TecnicoProdutor representa o vinculo entre um tecnico e um produtor.
type TecnicoProdutor struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	TecnicoID  uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:uq_tecnico_produtor" json:"tecnico_id" validate:"required"`
	ProdutorID uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:uq_tecnico_produtor" json:"produtor_id" validate:"required"`
	CreatedAt  time.Time `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Tecnico  Usuario `gorm:"foreignKey:TecnicoID" json:"tecnico,omitempty"`
	Produtor Usuario `gorm:"foreignKey:ProdutorID" json:"produtor,omitempty"`
}

func (TecnicoProdutor) TableName() string {
	return "tecnico_produtores"
}

func (tp *TecnicoProdutor) BeforeCreate(tx *gorm.DB) error {
	if tp.ID == uuid.Nil {
		tp.ID = uuid.New()
	}
	return nil
}
