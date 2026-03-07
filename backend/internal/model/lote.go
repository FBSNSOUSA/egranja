package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Lote representa um lote de aves em um galpao.
type Lote struct {
	ID                 uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UsuarioID          uuid.UUID  `gorm:"type:uuid;not null;index:idx_lotes_usuario;index:idx_lotes_status" json:"usuario_id" validate:"required"`
	GalpaoID           uuid.UUID  `gorm:"type:uuid;not null" json:"galpao_id" validate:"required"`
	DataAlojamento     time.Time  `gorm:"type:date;not null" json:"data_alojamento" validate:"required"`
	DataPrevistaAbate  time.Time  `gorm:"type:date;not null" json:"data_prevista_abate" validate:"required"`
	Quantidade         int        `gorm:"type:integer;not null" json:"quantidade" validate:"required,gt=0"`
	Tipo               string     `gorm:"type:varchar(10);not null" json:"tipo" validate:"required,oneof=Femea Macho Misto"`
	Linhagem           *string    `gorm:"type:varchar(50)" json:"linhagem,omitempty"`
	PesoInicialG       float64    `gorm:"type:numeric(8,2);not null;default:42.0" json:"peso_inicial_g"`
	Status             string     `gorm:"type:varchar(20);not null;default:'ativo';index:idx_lotes_status" json:"status" validate:"oneof=ativo finalizado"`
	DataFinalizacao    *time.Time `gorm:"type:date" json:"data_finalizacao,omitempty"`
	AvesEntregues      *int       `gorm:"type:integer" json:"aves_entregues,omitempty"`
	PesoTotalEntregue  *float64   `gorm:"type:numeric(12,3)" json:"peso_total_entregue,omitempty"`
	CreatedAt          time.Time  `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt          time.Time  `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Usuario           Usuario            `gorm:"foreignKey:UsuarioID" json:"-"`
	Galpao            Galpao             `gorm:"foreignKey:GalpaoID" json:"galpao,omitempty"`
	Pesagens          []Pesagem          `gorm:"foreignKey:LoteID" json:"pesagens,omitempty"`
	Mortalidades      []Mortalidade      `gorm:"foreignKey:LoteID" json:"mortalidades,omitempty"`
	FeedReceipts      []FeedReceipt      `gorm:"foreignKey:LoteID" json:"feed_receipts,omitempty"`
	FeedConsumptions  []FeedConsumption  `gorm:"foreignKey:LoteID" json:"feed_consumptions,omitempty"`
	WaterConsumptions []WaterConsumption `gorm:"foreignKey:LoteID" json:"water_consumptions,omitempty"`
	Checklists        []Checklist        `gorm:"foreignKey:LoteID" json:"checklists,omitempty"`
	Mensagens         []Mensagem         `gorm:"foreignKey:LoteID" json:"mensagens,omitempty"`
	Vacinacoes        []Vacinacao        `gorm:"foreignKey:LoteID" json:"vacinacoes,omitempty"`
	Medicamentos      []Medicamento      `gorm:"foreignKey:LoteID" json:"medicamentos,omitempty"`
	CustosLote        []CustoLote        `gorm:"foreignKey:LoteID" json:"custos_lote,omitempty"`
	Remuneracoes      []Remuneracao      `gorm:"foreignKey:LoteID" json:"remuneracoes,omitempty"`
}

func (Lote) TableName() string {
	return "lotes"
}

func (l *Lote) BeforeCreate(tx *gorm.DB) error {
	if l.ID == uuid.Nil {
		l.ID = uuid.New()
	}
	if l.Status == "" {
		l.Status = "ativo"
	}
	if l.PesoInicialG == 0 {
		l.PesoInicialG = 42.0
	}
	return nil
}

// DiasDeVida calcula a idade do lote em dias a partir da data de alojamento.
func (l *Lote) DiasDeVida() int {
	ref := time.Now()
	if l.DataFinalizacao != nil {
		ref = *l.DataFinalizacao
	}
	return int(ref.Sub(l.DataAlojamento).Hours() / 24)
}

// IsAtivo retorna true se o lote esta ativo.
func (l *Lote) IsAtivo() bool {
	return l.Status == "ativo"
}
