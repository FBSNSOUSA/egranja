package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// IAInteracao representa uma interacao com a IA (Gemini), incluindo cache de respostas.
type IAInteracao struct {
	ID            uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID        *uuid.UUID `gorm:"type:uuid;index:idx_ia_lote" json:"lote_id,omitempty"`
	UsuarioID     uuid.UUID  `gorm:"type:uuid;not null" json:"usuario_id" validate:"required"`
	Tipo          string     `gorm:"type:varchar(30);not null" json:"tipo" validate:"required,oneof=predicao_peso anomalia recomendacao analise_foto chat_assistente"`
	PromptResumo  *string    `gorm:"type:text" json:"prompt_resumo,omitempty"`
	Resposta      string     `gorm:"type:text;not null" json:"resposta" validate:"required"`
	Modelo        string     `gorm:"type:varchar(50);not null;default:'gemini-2.0-flash'" json:"modelo"`
	TokensUsados  *int       `gorm:"type:integer" json:"tokens_usados,omitempty"`
	CreatedAt     time.Time  `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Lote    *Lote   `gorm:"foreignKey:LoteID" json:"-"`
	Usuario Usuario `gorm:"foreignKey:UsuarioID" json:"-"`
}

func (IAInteracao) TableName() string {
	return "ia_interacoes"
}

func (i *IAInteracao) BeforeCreate(tx *gorm.DB) error {
	if i.ID == uuid.Nil {
		i.ID = uuid.New()
	}
	if i.Modelo == "" {
		i.Modelo = "gemini-2.0-flash"
	}
	return nil
}
