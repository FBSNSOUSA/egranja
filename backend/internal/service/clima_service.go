package service

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// PrevisaoTempo contém os dados brutos da previsão do tempo.
type PrevisaoTempo struct {
	Latitude  float64
	Longitude float64
	Horaria   []PrevisaoHoraria
	Diaria    []PrevisaoDiaria
}

// PrevisaoHoraria contém dados horários da previsão.
type PrevisaoHoraria struct {
	Hora                      string
	Temperatura               float64
	Umidade                   float64
	ProbabilidadePrecipitacao int
	PrecipitacaoMM            float64
	VentoKmh                  float64
	VentoDirecao              float64
}

// PrevisaoDiaria contém dados diários da previsão.
type PrevisaoDiaria struct {
	Data           string
	TemperaturaMax float64
	TemperaturaMin float64
	PrecipitacaoMM float64
	VentoMaxKmh    float64
}

// AlertaClima representa um alerta climático.
type AlertaClima struct {
	Tipo       string
	Severidade string
	Mensagem   string
	Valor      float64
	Limite     float64
	Data       string
}

// openMeteoHourlyResponse representa a resposta horária da API Open-Meteo.
type openMeteoHourlyResponse struct {
	Time                     []string  `json:"time"`
	Temperature2m            []float64 `json:"temperature_2m"`
	RelativeHumidity2m       []float64 `json:"relative_humidity_2m"`
	PrecipitationProbability []float64 `json:"precipitation_probability"`
	Precipitation            []float64 `json:"precipitation"`
	WindSpeed10m             []float64 `json:"wind_speed_10m"`
	WindDirection10m         []float64 `json:"wind_direction_10m"`
}

// openMeteoDailyResponse representa a resposta diária da API Open-Meteo.
type openMeteoDailyResponse struct {
	Time             []string  `json:"time"`
	Temperature2mMax []float64 `json:"temperature_2m_max"`
	Temperature2mMin []float64 `json:"temperature_2m_min"`
	PrecipitationSum []float64 `json:"precipitation_sum"`
	WindSpeed10mMax  []float64 `json:"wind_speed_10m_max"`
}

// openMeteoResponse representa a resposta completa da API Open-Meteo.
type openMeteoResponse struct {
	Latitude  float64                 `json:"latitude"`
	Longitude float64                 `json:"longitude"`
	Hourly    openMeteoHourlyResponse `json:"hourly"`
	Daily     openMeteoDailyResponse  `json:"daily"`
}

// ClimaService gerencia a consulta de previsao do tempo via Open-Meteo.
type ClimaService struct {
	httpClient *http.Client
	climaRepo  *repository.ClimaRepository
	logger     *zap.Logger
}

// NewClimaService cria uma nova instancia de ClimaService.
func NewClimaService(climaRepo *repository.ClimaRepository, logger *zap.Logger) *ClimaService {
	return &ClimaService{
		httpClient: &http.Client{
			Timeout: 10 * time.Second,
		},
		climaRepo: climaRepo,
		logger:    logger,
	}
}

// BuscarPrevisao busca a previsao do tempo na API Open-Meteo.
func (s *ClimaService) BuscarPrevisao(ctx context.Context, lat, lon float64) (*PrevisaoTempo, error) {
	url := fmt.Sprintf(
		"https://api.open-meteo.com/v1/forecast?latitude=%.7f&longitude=%.7f"+
			"&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,precipitation,wind_speed_10m,wind_direction_10m"+
			"&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,wind_speed_10m_max"+
			"&timezone=America/Sao_Paulo&forecast_days=7",
		lat, lon,
	)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("erro ao criar requisicao: %w", err)
	}

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("erro ao buscar previsao do tempo: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, _ := io.ReadAll(resp.Body)
		return nil, fmt.Errorf("API Open-Meteo retornou status %d: %s", resp.StatusCode, string(body))
	}

	var omResp openMeteoResponse
	if err := json.NewDecoder(resp.Body).Decode(&omResp); err != nil {
		return nil, fmt.Errorf("erro ao decodificar resposta Open-Meteo: %w", err)
	}

	previsao := &PrevisaoTempo{
		Latitude:  omResp.Latitude,
		Longitude: omResp.Longitude,
	}

	// Parse dados horários
	for i := range omResp.Hourly.Time {
		if i >= len(omResp.Hourly.Temperature2m) {
			break
		}

		h := PrevisaoHoraria{
			Hora:        omResp.Hourly.Time[i],
			Temperatura: omResp.Hourly.Temperature2m[i],
		}

		if i < len(omResp.Hourly.RelativeHumidity2m) {
			h.Umidade = omResp.Hourly.RelativeHumidity2m[i]
		}
		if i < len(omResp.Hourly.PrecipitationProbability) {
			h.ProbabilidadePrecipitacao = int(omResp.Hourly.PrecipitationProbability[i])
		}
		if i < len(omResp.Hourly.Precipitation) {
			h.PrecipitacaoMM = omResp.Hourly.Precipitation[i]
		}
		if i < len(omResp.Hourly.WindSpeed10m) {
			h.VentoKmh = omResp.Hourly.WindSpeed10m[i]
		}
		if i < len(omResp.Hourly.WindDirection10m) {
			h.VentoDirecao = omResp.Hourly.WindDirection10m[i]
		}

		previsao.Horaria = append(previsao.Horaria, h)
	}

	// Parse dados diários
	for i := range omResp.Daily.Time {
		if i >= len(omResp.Daily.Temperature2mMax) {
			break
		}

		d := PrevisaoDiaria{
			Data:           omResp.Daily.Time[i],
			TemperaturaMax: omResp.Daily.Temperature2mMax[i],
		}

		if i < len(omResp.Daily.Temperature2mMin) {
			d.TemperaturaMin = omResp.Daily.Temperature2mMin[i]
		}
		if i < len(omResp.Daily.PrecipitationSum) {
			d.PrecipitacaoMM = omResp.Daily.PrecipitationSum[i]
		}
		if i < len(omResp.Daily.WindSpeed10mMax) {
			d.VentoMaxKmh = omResp.Daily.WindSpeed10mMax[i]
		}

		previsao.Diaria = append(previsao.Diaria, d)
	}

	return previsao, nil
}

// SalvarPrevisao salva a previsao do tempo no banco para cache.
func (s *ClimaService) SalvarPrevisao(granjaID uuid.UUID, previsao *PrevisaoTempo) error {
	for _, d := range previsao.Diaria {
		data, err := time.Parse("2006-01-02", d.Data)
		if err != nil {
			s.logger.Warn("Data invalida na previsao", zap.String("data", d.Data))
			continue
		}

		p := &model.PrevisaoTempo{
			GranjaID:           granjaID,
			Data:               data,
			TemperaturaMin:     &d.TemperaturaMin,
			TemperaturaMax:     &d.TemperaturaMax,
			PrecipitacaoMM:     &d.PrecipitacaoMM,
			VentoVelocidadeKmh: &d.VentoMaxKmh,
			Provedor:           "open-meteo",
		}

		if err := s.climaRepo.Upsert(p); err != nil {
			s.logger.Error("Erro ao salvar previsao do tempo", zap.Error(err))
			continue
		}
	}

	return nil
}

// VerificarAlertasClima verifica se ha alertas climaticos na previsao.
func (s *ClimaService) VerificarAlertasClima(previsao *PrevisaoTempo) []AlertaClima {
	var alertas []AlertaClima

	for _, d := range previsao.Diaria {
		// Temperatura alta
		if d.TemperaturaMax > 35 {
			severidade := "media"
			if d.TemperaturaMax > 40 {
				severidade = "alta"
			}
			alertas = append(alertas, AlertaClima{
				Tipo:       "temperatura_alta",
				Severidade: severidade,
				Mensagem:   fmt.Sprintf("Temperatura maxima prevista de %.1f°C em %s. Risco de estresse termico.", d.TemperaturaMax, d.Data),
				Valor:      d.TemperaturaMax,
				Limite:     35,
				Data:       d.Data,
			})
		}

		// Temperatura baixa
		if d.TemperaturaMin < 10 {
			severidade := "media"
			if d.TemperaturaMin < 5 {
				severidade = "alta"
			}
			alertas = append(alertas, AlertaClima{
				Tipo:       "temperatura_baixa",
				Severidade: severidade,
				Mensagem:   fmt.Sprintf("Temperatura minima prevista de %.1f°C em %s. Risco de hipotermia.", d.TemperaturaMin, d.Data),
				Valor:      d.TemperaturaMin,
				Limite:     10,
				Data:       d.Data,
			})
		}

		// Vento forte
		if d.VentoMaxKmh > 40 {
			severidade := "media"
			if d.VentoMaxKmh > 60 {
				severidade = "alta"
			}
			alertas = append(alertas, AlertaClima{
				Tipo:       "vento_forte",
				Severidade: severidade,
				Mensagem:   fmt.Sprintf("Vento previsto de %.1f km/h em %s. Verificar estrutura do galpao.", d.VentoMaxKmh, d.Data),
				Valor:      d.VentoMaxKmh,
				Limite:     40,
				Data:       d.Data,
			})
		}

		// Chuva intensa
		if d.PrecipitacaoMM > 50 {
			severidade := "media"
			if d.PrecipitacaoMM > 100 {
				severidade = "alta"
			}
			alertas = append(alertas, AlertaClima{
				Tipo:       "chuva_intensa",
				Severidade: severidade,
				Mensagem:   fmt.Sprintf("Precipitacao prevista de %.1f mm em %s. Verificar drenagem.", d.PrecipitacaoMM, d.Data),
				Valor:      d.PrecipitacaoMM,
				Limite:     50,
				Data:       d.Data,
			})
		}
	}

	return alertas
}

// ToPrevisaoResponse converte PrevisaoTempo em PrevisaoTempoResponse.
func (s *ClimaService) ToPrevisaoResponse(galpaoID uuid.UUID, previsao *PrevisaoTempo) dto.PrevisaoTempoResponse {
	resp := dto.PrevisaoTempoResponse{
		GalpaoID:  galpaoID,
		Latitude:  previsao.Latitude,
		Longitude: previsao.Longitude,
		UpdatedAt: time.Now(),
	}

	for _, h := range previsao.Horaria {
		resp.Horaria = append(resp.Horaria, dto.PrevisaoHorariaDTO{
			Hora:                      h.Hora,
			Temperatura:               h.Temperatura,
			Umidade:                   h.Umidade,
			ProbabilidadePrecipitacao: h.ProbabilidadePrecipitacao,
			PrecipitacaoMM:            h.PrecipitacaoMM,
			VentoKmh:                  h.VentoKmh,
			VentoDirecao:              h.VentoDirecao,
		})
	}

	for _, d := range previsao.Diaria {
		resp.Diaria = append(resp.Diaria, dto.PrevisaoDiariaDTO{
			Data:           d.Data,
			TemperaturaMax: d.TemperaturaMax,
			TemperaturaMin: d.TemperaturaMin,
			PrecipitacaoMM: d.PrecipitacaoMM,
			VentoMaxKmh:    d.VentoMaxKmh,
		})
	}

	return resp
}

// ToAlertasResponse converte []AlertaClima em AlertasClimaListResponse.
func (s *ClimaService) ToAlertasResponse(galpaoID uuid.UUID, alertas []AlertaClima) dto.AlertasClimaListResponse {
	resp := dto.AlertasClimaListResponse{
		GalpaoID: galpaoID,
		Alertas:  make([]dto.AlertaClimaResponse, 0, len(alertas)),
	}

	for _, a := range alertas {
		resp.Alertas = append(resp.Alertas, dto.AlertaClimaResponse{
			Tipo:       a.Tipo,
			Severidade: a.Severidade,
			Mensagem:   a.Mensagem,
			Valor:      a.Valor,
			Limite:     a.Limite,
			Data:       a.Data,
		})
	}

	return resp
}
