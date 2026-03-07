package dto

import (
	"time"

	"github.com/google/uuid"
)

// PrevisaoDiariaDTO representa a previsao de um dia.
type PrevisaoDiariaDTO struct {
	Data              string  `json:"data"` // formato: YYYY-MM-DD
	TemperaturaMax    float64 `json:"temperatura_max"`
	TemperaturaMin    float64 `json:"temperatura_min"`
	PrecipitacaoMM    float64 `json:"precipitacao_mm"`
	VentoMaxKmh       float64 `json:"vento_max_kmh"`
}

// PrevisaoHorariaDTO representa a previsao de uma hora.
type PrevisaoHorariaDTO struct {
	Hora                   string  `json:"hora"` // formato: YYYY-MM-DDTHH:00
	Temperatura            float64 `json:"temperatura"`
	Umidade                float64 `json:"umidade"`
	ProbabilidadePrecipitacao int  `json:"probabilidade_precipitacao"`
	PrecipitacaoMM         float64 `json:"precipitacao_mm"`
	VentoKmh               float64 `json:"vento_kmh"`
	VentoDirecao           float64 `json:"vento_direcao"`
}

// PrevisaoTempoResponse representa a previsao completa do tempo.
type PrevisaoTempoResponse struct {
	GalpaoID  uuid.UUID             `json:"galpao_id"`
	Latitude  float64               `json:"latitude"`
	Longitude float64               `json:"longitude"`
	Horaria   []PrevisaoHorariaDTO  `json:"horaria"`
	Diaria    []PrevisaoDiariaDTO   `json:"diaria"`
	UpdatedAt time.Time             `json:"updated_at"`
}

// AlertaClimaResponse representa um alerta climatico.
type AlertaClimaResponse struct {
	Tipo      string  `json:"tipo"`      // temperatura_alta, temperatura_baixa, vento_forte, chuva_intensa
	Severidade string `json:"severidade"` // baixa, media, alta
	Mensagem  string  `json:"mensagem"`
	Valor     float64 `json:"valor"`
	Limite    float64 `json:"limite"`
	Data      string  `json:"data"`
}

// AlertasClimaListResponse representa a lista de alertas climaticos.
type AlertasClimaListResponse struct {
	GalpaoID uuid.UUID             `json:"galpao_id"`
	Alertas  []AlertaClimaResponse `json:"alertas"`
}
