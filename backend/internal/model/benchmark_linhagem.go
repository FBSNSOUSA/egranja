package model

import (
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// BenchmarkLinhagem representa os dados de referencia de uma linhagem por dia.
type BenchmarkLinhagem struct {
	ID           uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	Linhagem     string    `gorm:"type:varchar(50);not null;uniqueIndex:uq_benchmark_linhagem_dia" json:"linhagem" validate:"required,max=50"`
	Dia          int       `gorm:"type:integer;not null;uniqueIndex:uq_benchmark_linhagem_dia" json:"dia" validate:"required,gte=0"`
	PesoG        float64   `gorm:"type:numeric(10,2);not null;column:peso_g" json:"peso_g" validate:"required,gte=0"`
	ConsumoAcumG *float64  `gorm:"type:numeric(10,2);column:consumo_acum_g" json:"consumo_acum_g,omitempty"`
	CA           *float64  `gorm:"type:numeric(6,3);column:ca" json:"ca,omitempty"`
	GPDG         *float64  `gorm:"type:numeric(6,2);column:gpd_g" json:"gpd_g,omitempty"`
}

func (BenchmarkLinhagem) TableName() string {
	return "benchmarks_linhagem"
}

func (b *BenchmarkLinhagem) BeforeCreate(tx *gorm.DB) error {
	if b.ID == uuid.Nil {
		b.ID = uuid.New()
	}
	return nil
}
