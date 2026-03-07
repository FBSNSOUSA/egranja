package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Mensagem representa uma mensagem no chat produtor-tecnico vinculado a um lote.
type Mensagem struct {
	ID                 uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID             uuid.UUID  `gorm:"type:uuid;not null;index:idx_mensagens_lote" json:"lote_id" validate:"required"`
	RemetenteID        uuid.UUID  `gorm:"type:uuid;not null;index:idx_mensagens_remetente" json:"remetente_id" validate:"required"`
	Tipo               string     `gorm:"type:varchar(20);not null" json:"tipo" validate:"required,oneof=texto foto audio solicitacao visita"`
	Conteudo           *string    `gorm:"type:text" json:"conteudo,omitempty"`
	MidiaURL           *string    `gorm:"type:text;column:midia_url" json:"midia_url,omitempty"`
	MidiaThumbnailURL  *string    `gorm:"type:text;column:midia_thumbnail_url" json:"midia_thumbnail_url,omitempty"`
	SolicitacaoStatus  *string    `gorm:"type:varchar(20)" json:"solicitacao_status,omitempty" validate:"omitempty,oneof=pendente respondida expirada"`
	SolicitacaoPrazo   *time.Time `gorm:"type:timestamp" json:"solicitacao_prazo,omitempty"`
	Lida               bool       `gorm:"not null;default:false" json:"lida"`
	CreatedAt          time.Time  `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Lote      Lote    `gorm:"foreignKey:LoteID" json:"-"`
	Remetente Usuario `gorm:"foreignKey:RemetenteID" json:"remetente,omitempty"`
}

func (Mensagem) TableName() string {
	return "mensagens"
}

func (m *Mensagem) BeforeCreate(tx *gorm.DB) error {
	if m.ID == uuid.Nil {
		m.ID = uuid.New()
	}
	return nil
}
