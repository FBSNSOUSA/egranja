package model

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// IotReading representa uma leitura de sensor IoT em um galpao.
type IotReading struct {
	ID         uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	GalpaoID   uuid.UUID `gorm:"type:uuid;not null;index:idx_iot_galpao_tipo" json:"galpao_id" validate:"required"`
	SensorTipo string    `gorm:"type:varchar(30);not null;index:idx_iot_galpao_tipo" json:"sensor_tipo" validate:"required,oneof=temperatura umidade nh3 co2 peso agua racao luminosidade"`
	Valor      float64   `gorm:"type:numeric(12,3);not null" json:"valor" validate:"required"`
	Unidade    string    `gorm:"type:varchar(10);not null" json:"unidade" validate:"required,max=10"`
	Timestamp  time.Time `gorm:"type:timestamp;not null;default:now();index:idx_iot_galpao_tipo" json:"timestamp"`

	// Relacionamentos
	Galpao Galpao `gorm:"foreignKey:GalpaoID" json:"-"`
}

func (IotReading) TableName() string {
	return "iot_readings"
}

func (i *IotReading) BeforeCreate(tx *gorm.DB) error {
	if i.ID == uuid.Nil {
		i.ID = uuid.New()
	}
	if i.Timestamp.IsZero() {
		i.Timestamp = time.Now()
	}
	return nil
}
