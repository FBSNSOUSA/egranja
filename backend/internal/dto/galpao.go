package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateGalpaoRequest representa o payload de criacao de um galpao.
type CreateGalpaoRequest struct {
	GranjaID        *uuid.UUID `json:"granja_id,omitempty"`
	Nome            string     `json:"nome" validate:"required,max=100"`
	Capacidade      *int       `json:"capacidade,omitempty" validate:"omitempty,gt=0"`
	Latitude        *float64   `json:"latitude,omitempty"`
	Longitude       *float64   `json:"longitude,omitempty"`
	OrientacaoGraus *int       `json:"orientacao_graus,omitempty" validate:"omitempty,gte=0,lt=360"`
	ComprimentoM    *float64   `json:"comprimento_m,omitempty" validate:"omitempty,gt=0"`
	LarguraM        *float64   `json:"largura_m,omitempty" validate:"omitempty,gt=0"`
	TipoVentilacao  *string    `json:"tipo_ventilacao,omitempty" validate:"omitempty,oneof=convencional tunel dark_house misto"`
	LadoCortinas    *string    `json:"lado_cortinas,omitempty" validate:"omitempty,oneof=ambos norte sul leste oeste nenhum"`
}

// GalpaoResponse representa a resposta de um galpao.
type GalpaoResponse struct {
	ID              uuid.UUID  `json:"id"`
	UsuarioID       uuid.UUID  `json:"usuario_id"`
	GranjaID        *uuid.UUID `json:"granja_id,omitempty"`
	GranjaNome      string     `json:"granja_nome,omitempty"`
	Nome            string     `json:"nome"`
	Capacidade      *int       `json:"capacidade,omitempty"`
	Latitude        *float64   `json:"latitude,omitempty"`
	Longitude       *float64   `json:"longitude,omitempty"`
	OrientacaoGraus *int       `json:"orientacao_graus,omitempty"`
	ComprimentoM    *float64   `json:"comprimento_m,omitempty"`
	LarguraM        *float64   `json:"largura_m,omitempty"`
	AreaM2          *float64   `json:"area_m2,omitempty"`
	TipoVentilacao  *string    `json:"tipo_ventilacao,omitempty"`
	LadoCortinas    *string    `json:"lado_cortinas,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
	UpdatedAt       time.Time  `json:"updated_at"`
}
