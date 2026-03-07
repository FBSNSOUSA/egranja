package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateWaterConsumptionRequest representa o payload de registro de consumo de agua.
type CreateWaterConsumptionRequest struct {
	Data             string  `json:"data" validate:"required"` // formato: YYYY-MM-DD
	QuantidadeLitros float64 `json:"quantidade_litros" validate:"required,gt=0"`
}

// WaterConsumptionResponse representa a resposta de um consumo de agua.
type WaterConsumptionResponse struct {
	ID               uuid.UUID `json:"id"`
	LoteID           uuid.UUID `json:"lote_id"`
	Data             time.Time `json:"data"`
	QuantidadeLitros float64   `json:"quantidade_litros"`
	CreatedAt        time.Time `json:"created_at"`
}
