package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// GranjaColaborador representa o vinculo de colaboracao entre um usuario e uma granja.
type GranjaColaborador struct {
	ID           uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()"`
	GranjaID     uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:idx_granja_colab_unique,priority:1"`
	UsuarioID    uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:idx_granja_colab_unique,priority:2;index:idx_granja_colab_usuario"`
	Permissao    string    `gorm:"type:varchar(20);not null;default:'editor'"`
	ConvidadoPor uuid.UUID `gorm:"type:uuid;not null"`
	CreatedAt    time.Time `gorm:"not null;default:now()"`

	// Relacionamentos
	Granja    Granja  `gorm:"foreignKey:GranjaID"`
	Usuario   Usuario `gorm:"foreignKey:UsuarioID"`
	Convidado Usuario `gorm:"foreignKey:ConvidadoPor"`
}

// TableName define o nome da tabela no banco.
func (GranjaColaborador) TableName() string {
	return "granja_colaboradores"
}

// BeforeCreate gera o UUID antes de criar.
func (gc *GranjaColaborador) BeforeCreate(tx *gorm.DB) error {
	if gc.ID == uuid.Nil {
		gc.ID = uuid.New()
	}
	return nil
}

// IsEditor retorna se a permissao e de editor.
func (gc *GranjaColaborador) IsEditor() bool {
	return gc.Permissao == "editor"
}
