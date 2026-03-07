package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// WhatsappSendHistory representa o historico de envios de mensagens via WhatsApp.
type WhatsappSendHistory struct {
	ID                   uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	WhatsappRecipientID  uuid.UUID  `gorm:"type:uuid;not null;index:idx_wsh_recipient" json:"whatsapp_recipient_id" validate:"required"`
	PesagemID            *uuid.UUID `gorm:"type:uuid" json:"pesagem_id,omitempty"`
	MortalidadeID        *uuid.UUID `gorm:"type:uuid" json:"mortalidade_id,omitempty"`
	Mensagem             string     `gorm:"type:text;not null" json:"mensagem" validate:"required"`
	Status               string     `gorm:"type:varchar(20);not null" json:"status" validate:"required,oneof=enviado falha"`
	TipoEnvio            string     `gorm:"type:varchar(30);not null" json:"tipo_envio" validate:"required,oneof=pesagem mortalidade resumo_diario fechamento"`
	CreatedAt            time.Time  `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	WhatsappRecipient WhatsappRecipient `gorm:"foreignKey:WhatsappRecipientID" json:"-"`
	Pesagem           *Pesagem          `gorm:"foreignKey:PesagemID" json:"-"`
	Mortalidade       *Mortalidade      `gorm:"foreignKey:MortalidadeID" json:"-"`
}

func (WhatsappSendHistory) TableName() string {
	return "whatsapp_send_histories"
}

func (w *WhatsappSendHistory) BeforeCreate(tx *gorm.DB) error {
	if w.ID == uuid.Nil {
		w.ID = uuid.New()
	}
	return nil
}
