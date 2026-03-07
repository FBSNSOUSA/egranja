package dto

import (
	"time"

	"github.com/google/uuid"
)

// IoTReadingResponse representa uma leitura de sensor IoT.
type IoTReadingResponse struct {
	ID         uuid.UUID `json:"id"`
	GalpaoID   uuid.UUID `json:"galpao_id"`
	SensorTipo string    `json:"sensor_tipo"`
	Valor      float64   `json:"valor"`
	Unidade    string    `json:"unidade"`
	Timestamp  time.Time `json:"timestamp"`
}

// IoTLatestResponse representa a ultima leitura de cada tipo de sensor.
type IoTLatestResponse struct {
	GalpaoID uuid.UUID            `json:"galpao_id"`
	Sensores []IoTReadingResponse `json:"sensores"`
}

// IoTHistoricoRequest representa os parametros de consulta do historico IoT.
type IoTHistoricoRequest struct {
	From      string `form:"from" validate:"required"`      // formato: YYYY-MM-DDTHH:MM:SS
	To        string `form:"to" validate:"required"`        // formato: YYYY-MM-DDTHH:MM:SS
	Intervalo string `form:"intervalo" validate:"required,oneof=hora dia"` // hora ou dia
}

// IoTAgregadoItem representa um ponto agregado do historico IoT.
type IoTAgregadoItem struct {
	Periodo    time.Time `json:"periodo"`
	SensorTipo string    `json:"sensor_tipo"`
	Media      float64   `json:"media"`
	Minimo     float64   `json:"minimo"`
	Maximo     float64   `json:"maximo"`
	Contagem   int       `json:"contagem"`
}

// IoTHistoricoResponse representa a resposta do historico IoT agregado.
type IoTHistoricoResponse struct {
	GalpaoID  uuid.UUID         `json:"galpao_id"`
	Intervalo string            `json:"intervalo"`
	Dados     []IoTAgregadoItem `json:"dados"`
}
