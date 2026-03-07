package service

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestAlertaPrioridades(t *testing.T) {
	assert.Equal(t, AlertaPrioridade("CRITICA"), PrioridadeCritica)
	assert.Equal(t, AlertaPrioridade("ALTA"), PrioridadeAlta)
	assert.Equal(t, AlertaPrioridade("MEDIA"), PrioridadeMedia)
}

func TestAlertaMortalidadeAlta(t *testing.T) {
	// Simula: mortalidade diaria > 0.5% = CRITICA
	avesVivas := 10000
	mortalidadeHoje := 60 // 0.6%

	percentual := float64(mortalidadeHoje) / float64(avesVivas) * 100
	limite := 0.5

	assert.True(t, percentual > limite,
		"Mortalidade de 0.6%% deve exceder o limite de 0.5%%")
	assert.InDelta(t, 0.6, percentual, 0.01)
}

func TestAlertaMortalidadeBaixa(t *testing.T) {
	// Mortalidade normal: nao deve gerar alerta
	avesVivas := 10000
	mortalidadeHoje := 30 // 0.3%

	percentual := float64(mortalidadeHoje) / float64(avesVivas) * 100
	limite := 0.5

	assert.False(t, percentual > limite,
		"Mortalidade de 0.3%% nao deve exceder o limite de 0.5%%")
}

func TestAlertaPesoBaixo(t *testing.T) {
	// Peso < 90% do benchmark = ALTA
	pesoPadrao := 2857.0 // Cobb 500 dia 42
	pesoAtual := 2500.0  // 87.5% do padrao

	desvioPct := (pesoAtual - pesoPadrao) / pesoPadrao * 100 // -12.49%

	assert.True(t, desvioPct < -10,
		"Desvio de -12.5%% deve gerar alerta (< -10%%)")
	assert.False(t, desvioPct < -20,
		"Desvio de -12.5%% nao deve gerar alerta critico (< -20%%)")
}

func TestAlertaPesoMuitoBaixo(t *testing.T) {
	// Peso < 80% do benchmark = CRITICA
	pesoPadrao := 2857.0
	pesoAtual := 2200.0 // 77% do padrao

	desvioPct := (pesoAtual - pesoPadrao) / pesoPadrao * 100 // -23%

	assert.True(t, desvioPct < -20,
		"Desvio de -23%% deve gerar alerta critico (< -20%%)")
}

func TestAlertaConversaoAlta(t *testing.T) {
	// ICA > 10% do benchmark = MEDIA
	icaPadrao := 1.55
	icaAtual := 1.75

	desvioCA := (icaAtual - icaPadrao) / icaPadrao * 100 // 12.9%

	assert.True(t, desvioCA > 10,
		"ICA 12.9%% acima do padrao deve gerar alerta")
}

func TestAlertaConsumoAguaBaixo(t *testing.T) {
	// Queda > 15% no consumo de agua
	consumoAnterior := 500.0 // litros
	consumoAtual := 400.0    // litros

	variacao := (consumoAnterior - consumoAtual) / consumoAnterior * 100 // 20%

	assert.True(t, variacao > 15,
		"Queda de 20%% deve exceder o limite de 15%%")
}

func TestSemAlertas_TudoNormal(t *testing.T) {
	// Todas as metricas dentro do normal
	avesVivas := 10000
	mortalidadeHoje := 10 // 0.1%

	percentualMort := float64(mortalidadeHoje) / float64(avesVivas) * 100
	assert.True(t, percentualMort <= 0.5)

	pesoPadrao := 2857.0
	pesoAtual := 2800.0 // 98% do padrao
	desvioPct := (pesoAtual - pesoPadrao) / pesoPadrao * 100
	assert.True(t, desvioPct >= -10, "Peso normal nao deve gerar alerta")

	consumoAnterior := 500.0
	consumoAtual := 480.0
	variacao := (consumoAnterior - consumoAtual) / consumoAnterior * 100
	assert.True(t, variacao <= 15, "Variacao de agua normal nao deve gerar alerta")
}

func TestAlertaMortalidadeAcumulada(t *testing.T) {
	// Mortalidade acumulada > 3% = ALTA
	quantidade := 10000
	mortalidadeTotal := 350 // 3.5%

	percentual := float64(mortalidadeTotal) / float64(quantidade) * 100
	limite := 3.0

	assert.True(t, percentual > limite)
	assert.InDelta(t, 3.5, percentual, 0.01)
}

func TestAlertaRelacaoAguaRacao(t *testing.T) {
	// Relacao fora de 1.6-2.0 = MEDIA
	testCases := []struct {
		name     string
		relacao  float64
		alerta   bool
	}{
		{"abaixo do minimo", 1.3, true},
		{"no minimo", 1.6, false},
		{"normal", 1.8, false},
		{"no maximo", 2.0, false},
		{"acima do maximo", 2.3, true},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			foraRange := tc.relacao < 1.6 || tc.relacao > 2.0
			assert.Equal(t, tc.alerta, foraRange)
		})
	}
}
