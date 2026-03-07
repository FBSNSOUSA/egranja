package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// PrevisaoTempo representa os dados de previsao do tempo em cache para uma granja.
type PrevisaoTempo struct {
	ID                  uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	GranjaID            uuid.UUID `gorm:"type:uuid;not null;index:idx_previsoes_granja_data" json:"granja_id" validate:"required"`
	Data                time.Time `gorm:"type:date;not null;index:idx_previsoes_granja_data" json:"data" validate:"required"`
	TemperaturaMin      *float64  `gorm:"type:numeric(5,2)" json:"temperatura_min,omitempty"`
	TemperaturaMax      *float64  `gorm:"type:numeric(5,2)" json:"temperatura_max,omitempty"`
	UmidadeMin          *float64  `gorm:"type:numeric(5,2)" json:"umidade_min,omitempty"`
	UmidadeMax          *float64  `gorm:"type:numeric(5,2)" json:"umidade_max,omitempty"`
	PrecipitacaoMM      *float64  `gorm:"type:numeric(8,2)" json:"precipitacao_mm,omitempty"`
	ProbabilidadeChuva  *int      `gorm:"type:integer" json:"probabilidade_chuva,omitempty"`
	VentoVelocidadeKmh  *float64  `gorm:"type:numeric(6,2)" json:"vento_velocidade_kmh,omitempty"`
	VentoDirecao        *int      `gorm:"type:integer" json:"vento_direcao,omitempty"`
	IndiceUV            *float64  `gorm:"type:numeric(4,1)" json:"indice_uv,omitempty"`
	Provedor            string    `gorm:"type:varchar(30);not null;default:'open-meteo'" json:"provedor"`
	CreatedAt           time.Time `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Granja Granja `gorm:"foreignKey:GranjaID" json:"-"`
}

func (PrevisaoTempo) TableName() string {
	return "previsoes_tempo"
}

func (p *PrevisaoTempo) BeforeCreate(tx *gorm.DB) error {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	if p.Provedor == "" {
		p.Provedor = "open-meteo"
	}
	return nil
}
