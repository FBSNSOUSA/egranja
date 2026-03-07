package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Granja representa uma propriedade/granja (multi-granja).
type Granja struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UsuarioID uuid.UUID `gorm:"type:uuid;not null;index:idx_granjas_usuario" json:"usuario_id" validate:"required"`
	Nome      string    `gorm:"type:varchar(200);not null" json:"nome" validate:"required,max=200"`
	Endereco  string    `gorm:"type:text" json:"endereco,omitempty"`
	Cidade    string    `gorm:"type:varchar(100)" json:"cidade,omitempty" validate:"max=100"`
	Estado    string    `gorm:"type:varchar(2)" json:"estado,omitempty" validate:"max=2"`
	Latitude  *float64  `gorm:"type:numeric(10,7)" json:"latitude,omitempty"`
	Longitude *float64  `gorm:"type:numeric(10,7)" json:"longitude,omitempty"`
	CreatedAt time.Time `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt time.Time `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Usuario    Usuario     `gorm:"foreignKey:UsuarioID" json:"-"`
	Galpaos    []Galpao    `gorm:"foreignKey:GranjaID" json:"galpaos,omitempty"`
	Visitantes []Visitante `gorm:"foreignKey:GranjaID" json:"visitantes,omitempty"`
}

func (Granja) TableName() string {
	return "granjas"
}

func (g *Granja) BeforeCreate(tx *gorm.DB) error {
	if g.ID == uuid.Nil {
		g.ID = uuid.New()
	}
	return nil
}
