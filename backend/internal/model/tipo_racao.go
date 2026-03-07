package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// TipoRacao representa um tipo de racao disponivel.
type TipoRacao struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Nome      string    `gorm:"type:varchar(100);not null;uniqueIndex" json:"nome" validate:"required,max=100"`
	Ordem     int       `gorm:"type:integer;not null;default:0" json:"ordem"`
	CreatedAt time.Time `gorm:"not null;default:now()" json:"created_at"`
}

func (TipoRacao) TableName() string {
	return "tipos_racao"
}

func (t *TipoRacao) BeforeCreate(tx *gorm.DB) error {
	if t.ID == uuid.Nil {
		t.ID = uuid.New()
	}
	return nil
}
