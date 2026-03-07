package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// WhatsappRecipient representa um destinatario de WhatsApp para envio de relatorios.
type WhatsappRecipient struct {
	ID        uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID    uuid.UUID `gorm:"type:uuid;not null;uniqueIndex:uq_wa_recipient_lote_numero" json:"lote_id" validate:"required"`
	Numero    string    `gorm:"type:varchar(20);not null;uniqueIndex:uq_wa_recipient_lote_numero" json:"numero" validate:"required,max=20"`
	Nome      *string   `gorm:"type:varchar(200)" json:"nome,omitempty" validate:"omitempty,max=200"`
	CreatedAt time.Time `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Lote          Lote                   `gorm:"foreignKey:LoteID" json:"-"`
	SendHistories []WhatsappSendHistory  `gorm:"foreignKey:WhatsappRecipientID" json:"send_histories,omitempty"`
}

func (WhatsappRecipient) TableName() string {
	return "whatsapp_recipients"
}

func (w *WhatsappRecipient) BeforeCreate(tx *gorm.DB) error {
	if w.ID == uuid.Nil {
		w.ID = uuid.New()
	}
	return nil
}
