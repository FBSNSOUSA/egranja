package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Visitante representa o registro de um visitante na granja (livro de registro digital).
type Visitante struct {
	ID                 uuid.UUID  `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	GranjaID           uuid.UUID  `gorm:"type:uuid;not null;index:idx_visitantes_granja" json:"granja_id" validate:"required"`
	Nome               string     `gorm:"type:varchar(200);not null" json:"nome" validate:"required,max=200"`
	Documento          *string    `gorm:"type:varchar(50)" json:"documento,omitempty" validate:"omitempty,max=50"`
	Origem             *string    `gorm:"type:varchar(200)" json:"origem,omitempty" validate:"omitempty,max=200"`
	Motivo             *string    `gorm:"type:varchar(200)" json:"motivo,omitempty" validate:"omitempty,max=200"`
	UltimoContatoAves  *time.Time `gorm:"type:date" json:"ultimo_contato_aves,omitempty"`
	PlacaVeiculo       *string    `gorm:"type:varchar(20)" json:"placa_veiculo,omitempty" validate:"omitempty,max=20"`
	DataEntrada        time.Time  `gorm:"type:timestamp;not null" json:"data_entrada" validate:"required"`
	DataSaida          *time.Time `gorm:"type:timestamp" json:"data_saida,omitempty"`
	Observacao         *string    `gorm:"type:text" json:"observacao,omitempty"`
	CreatedAt          time.Time  `gorm:"not null;default:now()" json:"created_at"`

	// Relacionamentos
	Granja Granja `gorm:"foreignKey:GranjaID" json:"-"`
}

func (Visitante) TableName() string {
	return "visitantes"
}

func (v *Visitante) BeforeCreate(tx *gorm.DB) error {
	if v.ID == uuid.Nil {
		v.ID = uuid.New()
	}
	return nil
}
