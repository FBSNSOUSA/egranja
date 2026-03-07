package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// FeedReceipt representa um recebimento de racao para um lote.
type FeedReceipt struct {
	ID              uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID          uuid.UUID  `gorm:"type:uuid;index:idx_feed_receipts_lote" json:"lote_id" validate:"required"`
	TipoRacaoID     *uuid.UUID `gorm:"type:uuid" json:"tipo_racao_id,omitempty"`
	QuantidadeKg    float64    `gorm:"type:numeric(12,3);not null" json:"quantidade_kg" validate:"required,gt=0"`
	DataRecebimento time.Time  `gorm:"type:date;not null" json:"data_recebimento" validate:"required"`
	Fornecedor      *string    `gorm:"type:varchar(200)" json:"fornecedor,omitempty" validate:"omitempty,max=200"`
	LoteRacao       *string    `gorm:"type:varchar(100);column:lote_racao" json:"lote_racao,omitempty" validate:"omitempty,max=100"`
	Origem          string     `gorm:"type:varchar(30);not null;default:'compra'" json:"origem" validate:"oneof=compra remanescente_anterior sobra_final"`
	CreatedAt       time.Time  `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt       time.Time  `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Lote      Lote       `gorm:"foreignKey:LoteID" json:"-"`
	TipoRacao *TipoRacao `gorm:"foreignKey:TipoRacaoID" json:"tipo_racao,omitempty"`
}

func (FeedReceipt) TableName() string {
	return "feed_receipts"
}

func (f *FeedReceipt) BeforeCreate(tx *gorm.DB) error {
	if f.ID == uuid.Nil {
		f.ID = uuid.New()
	}
	if f.Origem == "" {
		f.Origem = "compra"
	}
	return nil
}
