package model

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// RastreabilidadeChain representa um elo da cadeia de rastreabilidade (blockchain simplificada).
type RastreabilidadeChain struct {
	ID            uuid.UUID       `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	LoteID        uuid.UUID       `gorm:"type:uuid;not null;index:idx_rastreabilidade_lote" json:"lote_id" validate:"required"`
	Evento        string          `gorm:"type:varchar(50);not null" json:"evento" validate:"required,max=50"`
	Dados         json.RawMessage `gorm:"type:jsonb;not null" json:"dados" validate:"required"`
	HashAtual     string          `gorm:"type:varchar(64);not null;column:hash_atual" json:"hash_atual"`
	HashAnterior  *string         `gorm:"type:varchar(64);column:hash_anterior" json:"hash_anterior,omitempty"`
	CreatedAt     time.Time       `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Lote Lote `gorm:"foreignKey:LoteID" json:"-"`
}

func (RastreabilidadeChain) TableName() string {
	return "rastreabilidade_chain"
}

func (r *RastreabilidadeChain) BeforeCreate(tx *gorm.DB) error {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	// Calcula o hash SHA-256 do bloco
	if r.HashAtual == "" {
		r.HashAtual = r.CalculaHash()
	}
	return nil
}

// CalculaHash gera o hash SHA-256 do bloco baseado nos dados, evento, lote_id e hash anterior.
func (r *RastreabilidadeChain) CalculaHash() string {
	hashAnterior := ""
	if r.HashAnterior != nil {
		hashAnterior = *r.HashAnterior
	}
	data := fmt.Sprintf("%s|%s|%s|%s|%s",
		r.LoteID.String(),
		r.Evento,
		string(r.Dados),
		hashAnterior,
		r.CreatedAt.UTC().Format(time.RFC3339Nano),
	)
	hash := sha256.Sum256([]byte(data))
	return fmt.Sprintf("%x", hash)
}
