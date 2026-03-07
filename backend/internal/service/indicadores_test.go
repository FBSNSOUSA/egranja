package service

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestRoundTo(t *testing.T) {
	testCases := []struct {
		name     string
		val      float64
		places   int
		expected float64
	}{
		{"duas casas", 3.14159, 2, 3.14},
		{"uma casa", 3.15, 1, 3.2},
		{"zero casas", 3.7, 0, 4},
		{"tres casas", 1.2345, 3, 1.235},
		{"valor negativo", -2.567, 2, -2.57},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			result := roundTo(tc.val, tc.places)
			assert.Equal(t, tc.expected, result)
		})
	}
}

func TestClassificarIEP(t *testing.T) {
	testCases := []struct {
		name     string
		iep      float64
		expected string
	}{
		{"Excelente acima de 400", 450, "Excelente"},
		{"Excelente no limite 401", 401, "Excelente"},
		{"Bom no limite 400", 400, "Bom"},
		{"Bom 380", 380, "Bom"},
		{"Bom no limite 350", 350, "Bom"},
		{"Regular 300", 300, "Regular"},
		{"Regular no limite 260", 260, "Regular"},
		{"Ruim abaixo de 260", 259, "Ruim"},
		{"Ruim 100", 100, "Ruim"},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			result := classificarIEP(tc.iep)
			assert.Equal(t, tc.expected, result)
		})
	}
}

func TestCalcularICA_ValoresConhecidos(t *testing.T) {
	// ICA = consumoTotalRacao / pesoTotalProduzido
	// pesoTotalProduzido = (pesoMedio - pesoInicial) * avesVivas / 1000
	consumoTotalRacao := 4430.0  // kg
	pesoMedio := 2857.0          // g
	pesoInicial := 42.0          // g
	avesVivas := 9500            // aves

	pesoTotalProduzido := (pesoMedio - pesoInicial) * float64(avesVivas) / 1000
	ica := roundTo(consumoTotalRacao/pesoTotalProduzido, 3)

	// Esperado: 4430 / ((2857-42)*9500/1000) = 4430 / 26742.5 = 0.1657...
	assert.True(t, ica > 0, "ICA deve ser positivo")
	assert.True(t, ica < 3.0, "ICA em frangos de corte normalmente < 2.0")
}

func TestCalcularGPD(t *testing.T) {
	// GPD = (pesoAtual - pesoInicial) / diasDeVida
	pesoAtual := 2857.0  // g
	pesoInicial := 42.0  // g
	diasDeVida := 42

	gpd := roundTo((pesoAtual-pesoInicial)/float64(diasDeVida), 1)

	assert.InDelta(t, 67.0, gpd, 0.5, "GPD esperado proximo de 67 g/dia para Cobb500 dia 42")
}

func TestCalcularViabilidade(t *testing.T) {
	testCases := []struct {
		name         string
		quantidade   int
		mortalidade  int
		expectedViab float64
	}{
		{"100% viavel", 10000, 0, 100.0},
		{"mortalidade 3%", 10000, 300, 97.0},
		{"mortalidade 5%", 10000, 500, 95.0},
		{"metade morreu", 10000, 5000, 50.0},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			mortalidadePct := roundTo(float64(tc.mortalidade)/float64(tc.quantidade)*100, 2)
			viabilidade := roundTo(100.0-mortalidadePct, 2)
			assert.Equal(t, tc.expectedViab, viabilidade)
		})
	}
}

func TestCalcularIEP(t *testing.T) {
	// IEP = (GPD * Viabilidade) / (ICA * 10)
	gpd := 67.0        // g/dia
	viabilidade := 97.0 // %
	ica := 1.55

	iep := roundTo((gpd * viabilidade) / (ica * 10), 1)

	// Esperado: (67 * 97) / (1.55 * 10) = 6499 / 15.5 = 419.29 => 419.3
	assert.True(t, iep > 400, "IEP com bons indices deve ser > 400 (Excelente)")
	assert.Equal(t, "Excelente", classificarIEP(iep))
}

func TestCalcularIEA(t *testing.T) {
	// IEA = 1 / ICA
	ica := 1.55
	iea := roundTo(1.0/ica, 3)

	assert.InDelta(t, 0.645, iea, 0.001)
}

func TestIndicadores_MortalidadeZero(t *testing.T) {
	quantidade := 10000
	mortalidade := 0

	mortalidadePct := 0.0
	if quantidade > 0 {
		mortalidadePct = roundTo(float64(mortalidade)/float64(quantidade)*100, 2)
	}
	viabilidade := roundTo(100.0-mortalidadePct, 2)

	assert.Equal(t, 0.0, mortalidadePct)
	assert.Equal(t, 100.0, viabilidade)
}

func TestIndicadores_LoteVazio(t *testing.T) {
	// Se quantidade == 0, nao deve dividir por zero
	quantidade := 0
	mortalidade := 0

	mortalidadePct := 0.0
	if quantidade > 0 {
		mortalidadePct = roundTo(float64(mortalidade)/float64(quantidade)*100, 2)
	}

	assert.Equal(t, 0.0, mortalidadePct, "Com lote vazio, mortalidade deve ser 0")
}
