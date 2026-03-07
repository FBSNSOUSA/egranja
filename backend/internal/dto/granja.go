package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateGranjaRequest representa o payload de criacao de uma granja.
type CreateGranjaRequest struct {
	Nome      string   `json:"nome" validate:"required,max=200"`
	Endereco  *string  `json:"endereco,omitempty"`
	Cidade    *string  `json:"cidade,omitempty" validate:"omitempty,max=100"`
	Estado    *string  `json:"estado,omitempty" validate:"omitempty,max=2"`
	Latitude  *float64 `json:"latitude,omitempty"`
	Longitude *float64 `json:"longitude,omitempty"`
}

// GranjaResponse representa a resposta de uma granja.
type GranjaResponse struct {
	ID          uuid.UUID       `json:"id"`
	UsuarioID   uuid.UUID       `json:"usuario_id"`
	Nome        string          `json:"nome"`
	Endereco    string          `json:"endereco,omitempty"`
	Cidade      string          `json:"cidade,omitempty"`
	Estado      string          `json:"estado,omitempty"`
	Latitude    *float64        `json:"latitude,omitempty"`
	Longitude   *float64        `json:"longitude,omitempty"`
	TotalGalpaos int            `json:"total_galpaos"`
	TotalLotesAtivos int        `json:"total_lotes_ativos"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
}

// DashboardConsolidadoResponse representa o dashboard consolidado de todas as granjas.
type DashboardConsolidadoResponse struct {
	TotalGranjas     int     `json:"total_granjas"`
	TotalGalpaos     int     `json:"total_galpaos"`
	TotalLotesAtivos int     `json:"total_lotes_ativos"`
	TotalAves        int     `json:"total_aves"`
	TotalAvesVivas   int     `json:"total_aves_vivas"`
	MortalidadeMedia float64 `json:"mortalidade_media"`
	IEPMedio         float64 `json:"iep_medio,omitempty"`
	Granjas          []GranjaResumoDTO `json:"granjas"`
}

// GranjaResumoDTO representa o resumo de uma granja no dashboard consolidado.
type GranjaResumoDTO struct {
	ID               uuid.UUID `json:"id"`
	Nome             string    `json:"nome"`
	TotalGalpaos     int       `json:"total_galpaos"`
	TotalLotesAtivos int       `json:"total_lotes_ativos"`
	TotalAves        int       `json:"total_aves"`
	TotalAvesVivas   int       `json:"total_aves_vivas"`
}

// ComparativoGranjaResponse representa a resposta do comparativo entre granjas.
type ComparativoGranjaResponse struct {
	Granjas []GranjaComparativoDTO `json:"granjas"`
}

// GranjaComparativoDTO representa os dados comparativos de uma granja.
type GranjaComparativoDTO struct {
	ID               uuid.UUID `json:"id"`
	Nome             string    `json:"nome"`
	TotalLotes       int       `json:"total_lotes"`
	MortalidadeMedia float64   `json:"mortalidade_media"`
	PesoMedio        float64   `json:"peso_medio"`
	IEPMedio         float64   `json:"iep_medio"`
}
