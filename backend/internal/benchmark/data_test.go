package benchmark

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestCobb500Data_Day0(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 0)
	require.NotNil(t, peso)
	assert.Equal(t, 42.0, *peso)
}

func TestCobb500Data_Day1(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 1)
	require.NotNil(t, peso)
	fator := float64(1-0) / float64(7-0)
	expected := 42.0 + fator*(202.0-42.0)
	expectedRounded := float64(int(expected*100+0.5)) / 100
	assert.InDelta(t, expectedRounded, *peso, 0.01)
}

func TestCobb500Data_Day7(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 7)
	require.NotNil(t, peso)
	assert.Equal(t, 202.0, *peso)
}

func TestCobb500Data_Day14(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 14)
	require.NotNil(t, peso)
	assert.Equal(t, 570.0, *peso)
}

func TestCobb500Data_Day21(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 21)
	require.NotNil(t, peso)
	assert.Equal(t, 1116.0, *peso)
}

func TestCobb500Data_Day28(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 28)
	require.NotNil(t, peso)
	assert.Equal(t, 1656.0, *peso)
}

func TestCobb500Data_Day35(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 35)
	require.NotNil(t, peso)
	assert.Equal(t, 2348.0, *peso)
}

func TestCobb500Data_Day42(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 42)
	require.NotNil(t, peso)
	assert.Equal(t, 2857.0, *peso)
}

func TestRoss308Data_Day0(t *testing.T) {
	peso := GetPesoPadrao("Ross 308", 0)
	require.NotNil(t, peso)
	assert.Equal(t, 42.0, *peso)
}

func TestRoss308Data_Day7(t *testing.T) {
	peso := GetPesoPadrao("Ross 308", 7)
	require.NotNil(t, peso)
	assert.Equal(t, 197.0, *peso)
}

func TestRoss308Data_Day42(t *testing.T) {
	peso := GetPesoPadrao("Ross 308", 42)
	require.NotNil(t, peso)
	assert.Equal(t, 3203.0, *peso)
}

func TestInterpolacao_DiaIntermediario(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 10)
	require.NotNil(t, peso)
	fator := float64(10-7) / float64(14-7)
	expected := 202.0 + fator*(570.0-202.0)
	expectedRounded := float64(int(expected*100+0.5)) / 100
	assert.InDelta(t, expectedRounded, *peso, 0.01)
}

func TestInterpolacao_DiaExato(t *testing.T) {
	testCases := []struct {
		name     string
		linhagem string
		dia      int
		expected float64
	}{
		{"Cobb500 dia 0", "Cobb 500", 0, 42},
		{"Cobb500 dia 7", "Cobb 500", 7, 202},
		{"Cobb500 dia 49", "Cobb 500", 49, 3414},
		{"Ross308 dia 14", "Ross 308", 14, 545},
		{"Ross308 dia 49", "Ross 308", 49, 3900},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			peso := GetPesoPadrao(tc.linhagem, tc.dia)
			require.NotNil(t, peso)
			assert.Equal(t, tc.expected, *peso)
		})
	}
}

func TestInterpolacao_DiaForaDoRange(t *testing.T) {
	peso := GetPesoPadrao("Cobb 500", 55)
	require.NotNil(t, peso)
	assert.True(t, *peso > 3414.0, "Peso extrapolado deve ser maior que o ultimo ponto da tabela")
}

func TestGetBenchmarkData_LinhagemInexistente(t *testing.T) {
	data := GetBenchmarkData("Inexistente")
	assert.Nil(t, data)

	peso := GetPesoPadrao("Inexistente", 10)
	assert.Nil(t, peso)
}

func TestGetConsumoAcumPadrao(t *testing.T) {
	consumo := GetConsumoAcumPadrao("Cobb 500", 7)
	require.NotNil(t, consumo)
	assert.Equal(t, 180.0, *consumo)

	consumo = GetConsumoAcumPadrao("Cobb 500", 10)
	require.NotNil(t, consumo)
	assert.True(t, *consumo > 180.0 && *consumo < 588.0)

	consumo = GetConsumoAcumPadrao("Inexistente", 7)
	assert.Nil(t, consumo)
}

func TestGetCAPadrao(t *testing.T) {
	ca := GetCAPadrao("Cobb 500", 7)
	require.NotNil(t, ca)
	assert.Equal(t, 0.891, *ca)

	ca = GetCAPadrao("Cobb 500", 10)
	require.NotNil(t, ca)
	assert.True(t, *ca > 0.891 && *ca < 1.029)

	ca = GetCAPadrao("Inexistente", 7)
	assert.Nil(t, ca)
}

func TestListLinhagens(t *testing.T) {
	linhagens := ListLinhagens()
	assert.Len(t, linhagens, 2)
	assert.Contains(t, linhagens, "Cobb 500")
	assert.Contains(t, linhagens, "Ross 308")
}
