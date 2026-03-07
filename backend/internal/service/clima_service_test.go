package service

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestVerificarAlertasClima_TemperaturaAlta(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-03-10", TemperaturaMax: 38, TemperaturaMin: 22, PrecipitacaoMM: 0, VentoMaxKmh: 10},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	require.Len(t, alertas, 1)
	assert.Equal(t, "temperatura_alta", alertas[0].Tipo)
	assert.Equal(t, "media", alertas[0].Severidade)
	assert.Equal(t, 38.0, alertas[0].Valor)
	assert.Equal(t, 35.0, alertas[0].Limite)
}

func TestVerificarAlertasClima_TemperaturaMuitoAlta(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-03-10", TemperaturaMax: 42, TemperaturaMin: 28, PrecipitacaoMM: 0, VentoMaxKmh: 10},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	require.Len(t, alertas, 1)
	assert.Equal(t, "temperatura_alta", alertas[0].Tipo)
	assert.Equal(t, "alta", alertas[0].Severidade)
}

func TestVerificarAlertasClima_TemperaturaBaixa(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-07-15", TemperaturaMax: 18, TemperaturaMin: 7, PrecipitacaoMM: 0, VentoMaxKmh: 10},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	require.Len(t, alertas, 1)
	assert.Equal(t, "temperatura_baixa", alertas[0].Tipo)
	assert.Equal(t, "media", alertas[0].Severidade)
	assert.Equal(t, 7.0, alertas[0].Valor)
	assert.Equal(t, 10.0, alertas[0].Limite)
}

func TestVerificarAlertasClima_TemperaturaMuitoBaixa(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-07-15", TemperaturaMax: 12, TemperaturaMin: 3, PrecipitacaoMM: 0, VentoMaxKmh: 10},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	require.Len(t, alertas, 1)
	assert.Equal(t, "temperatura_baixa", alertas[0].Tipo)
	assert.Equal(t, "alta", alertas[0].Severidade)
}

func TestVerificarAlertasClima_VentoForte(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-03-10", TemperaturaMax: 28, TemperaturaMin: 18, PrecipitacaoMM: 0, VentoMaxKmh: 50},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	require.Len(t, alertas, 1)
	assert.Equal(t, "vento_forte", alertas[0].Tipo)
	assert.Equal(t, "media", alertas[0].Severidade)
	assert.Equal(t, 50.0, alertas[0].Valor)
	assert.Equal(t, 40.0, alertas[0].Limite)
}

func TestVerificarAlertasClima_VentoMuitoForte(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-03-10", TemperaturaMax: 28, TemperaturaMin: 18, PrecipitacaoMM: 0, VentoMaxKmh: 70},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	require.Len(t, alertas, 1)
	assert.Equal(t, "vento_forte", alertas[0].Tipo)
	assert.Equal(t, "alta", alertas[0].Severidade)
}

func TestVerificarAlertasClima_ChuvaIntensa(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-03-10", TemperaturaMax: 28, TemperaturaMin: 18, PrecipitacaoMM: 75, VentoMaxKmh: 10},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	require.Len(t, alertas, 1)
	assert.Equal(t, "chuva_intensa", alertas[0].Tipo)
	assert.Equal(t, "media", alertas[0].Severidade)
	assert.Equal(t, 75.0, alertas[0].Valor)
	assert.Equal(t, 50.0, alertas[0].Limite)
}

func TestVerificarAlertasClima_ChuvaMuitoIntensa(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-03-10", TemperaturaMax: 28, TemperaturaMin: 18, PrecipitacaoMM: 120, VentoMaxKmh: 10},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	require.Len(t, alertas, 1)
	assert.Equal(t, "chuva_intensa", alertas[0].Tipo)
	assert.Equal(t, "alta", alertas[0].Severidade)
}

func TestVerificarAlertasClima_Normal(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-03-10", TemperaturaMax: 28, TemperaturaMin: 18, PrecipitacaoMM: 5, VentoMaxKmh: 15},
			{Data: "2026-03-11", TemperaturaMax: 30, TemperaturaMin: 20, PrecipitacaoMM: 0, VentoMaxKmh: 10},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	assert.Empty(t, alertas, "Condicoes normais nao devem gerar alertas")
}

func TestVerificarAlertasClima_MultiplosAlertas(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{
			{Data: "2026-03-10", TemperaturaMax: 42, TemperaturaMin: 28, PrecipitacaoMM: 80, VentoMaxKmh: 55},
		},
	}

	alertas := svc.VerificarAlertasClima(previsao)

	assert.Len(t, alertas, 3, "Deve gerar alertas de temperatura alta, vento forte e chuva intensa")

	tipos := make(map[string]bool)
	for _, a := range alertas {
		tipos[a.Tipo] = true
	}
	assert.True(t, tipos["temperatura_alta"])
	assert.True(t, tipos["vento_forte"])
	assert.True(t, tipos["chuva_intensa"])
}

func TestVerificarAlertasClima_PrevisaoVazia(t *testing.T) {
	svc := &ClimaService{}
	previsao := &PrevisaoTempo{
		Diaria: []PrevisaoDiaria{},
	}

	alertas := svc.VerificarAlertasClima(previsao)
	assert.Empty(t, alertas)
}
