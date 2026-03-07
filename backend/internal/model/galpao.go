package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Galpao representa um galpao/aviario dentro de uma granja.
type Galpao struct {
	ID              uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UsuarioID       uuid.UUID  `gorm:"type:uuid;not null" json:"usuario_id" validate:"required"`
	GranjaID        *uuid.UUID `gorm:"type:uuid;index" json:"granja_id,omitempty"`
	Nome            string     `gorm:"type:varchar(100);not null" json:"nome" validate:"required,max=100"`
	Capacidade      *int       `gorm:"type:integer" json:"capacidade,omitempty" validate:"omitempty,gt=0"`
	Latitude        *float64   `gorm:"type:numeric(10,7)" json:"latitude,omitempty"`
	Longitude       *float64   `gorm:"type:numeric(10,7)" json:"longitude,omitempty"`
	OrientacaoGraus *int       `gorm:"type:integer" json:"orientacao_graus,omitempty" validate:"omitempty,gte=0,lt=360"`
	ComprimentoM    *float64   `gorm:"type:numeric(8,2)" json:"comprimento_m,omitempty" validate:"omitempty,gt=0"`
	LarguraM        *float64   `gorm:"type:numeric(8,2)" json:"largura_m,omitempty" validate:"omitempty,gt=0"`
	TipoVentilacao  *string    `gorm:"type:varchar(30)" json:"tipo_ventilacao,omitempty" validate:"omitempty,oneof=convencional tunel dark_house misto"`
	LadoCortinas    *string    `gorm:"type:varchar(20)" json:"lado_cortinas,omitempty" validate:"omitempty,oneof=ambos norte sul leste oeste nenhum"`
	CreatedAt       time.Time  `gorm:"not null;default:now()" json:"created_at"`
	UpdatedAt       time.Time  `gorm:"not null;default:now()" json:"updated_at"`

	// Relacionamentos
	Usuario    Usuario      `gorm:"foreignKey:UsuarioID" json:"-"`
	Granja     *Granja      `gorm:"foreignKey:GranjaID" json:"-"`
	Lotes      []Lote       `gorm:"foreignKey:GalpaoID" json:"lotes,omitempty"`
	IotReadings []IotReading `gorm:"foreignKey:GalpaoID" json:"iot_readings,omitempty"`
}

func (Galpao) TableName() string {
	return "galpaos"
}

func (g *Galpao) BeforeCreate(tx *gorm.DB) error {
	if g.ID == uuid.Nil {
		g.ID = uuid.New()
	}
	return nil
}

// AreaM2 calcula a area do galpao em metros quadrados.
func (g *Galpao) AreaM2() *float64 {
	if g.ComprimentoM != nil && g.LarguraM != nil {
		area := *g.ComprimentoM * *g.LarguraM
		return &area
	}
	return nil
}

// DensidadeAvesM2 calcula a densidade de aves por m2 dado um numero de aves.
func (g *Galpao) DensidadeAvesM2(aves int) *float64 {
	area := g.AreaM2()
	if area != nil && *area > 0 {
		d := float64(aves) / *area
		return &d
	}
	return nil
}
