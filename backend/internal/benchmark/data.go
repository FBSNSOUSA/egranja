package benchmark

import "math"

// BenchmarkEntry representa uma entrada de benchmark para um dia especifico.
type BenchmarkEntry struct {
	Dia          int
	PesoG        float64
	GPDG         float64
	ConsumoAcumG float64
	CA           float64
}

// Cobb500 contem os dados de referencia da linhagem Cobb 500 (Misto - 2022).
// Fonte: Cobb 500 Performance & Nutrition Supplement 2022
var Cobb500 = []BenchmarkEntry{
	{Dia: 0, PesoG: 42, GPDG: 0, ConsumoAcumG: 0, CA: 0},
	{Dia: 7, PesoG: 202, GPDG: 22.9, ConsumoAcumG: 180, CA: 0.891},
	{Dia: 14, PesoG: 570, GPDG: 37.7, ConsumoAcumG: 588, CA: 1.029},
	{Dia: 21, PesoG: 1116, GPDG: 51.1, ConsumoAcumG: 1320, CA: 1.182},
	{Dia: 28, PesoG: 1656, GPDG: 57.6, ConsumoAcumG: 2359, CA: 1.322},
	{Dia: 35, PesoG: 2348, GPDG: 65.9, ConsumoAcumG: 3448, CA: 1.469},
	{Dia: 42, PesoG: 2857, GPDG: 67.0, ConsumoAcumG: 4430, CA: 1.550},
	{Dia: 49, PesoG: 3414, GPDG: 68.8, ConsumoAcumG: 5600, CA: 1.640},
}

// Ross308 contem os dados de referencia da linhagem Ross 308 (Misto - 2022).
// Fonte: Aviagen Ross 308 Performance Objectives 2022
var Ross308 = []BenchmarkEntry{
	{Dia: 0, PesoG: 42, GPDG: 0, ConsumoAcumG: 0, CA: 0},
	{Dia: 7, PesoG: 197, GPDG: 22.1, ConsumoAcumG: 177, CA: 0.900},
	{Dia: 14, PesoG: 545, GPDG: 36.0, ConsumoAcumG: 568, CA: 1.042},
	{Dia: 21, PesoG: 1070, GPDG: 48.9, ConsumoAcumG: 1274, CA: 1.191},
	{Dia: 28, PesoG: 1728, GPDG: 60.2, ConsumoAcumG: 2292, CA: 1.326},
	{Dia: 35, PesoG: 2464, GPDG: 68.9, ConsumoAcumG: 3592, CA: 1.458},
	{Dia: 42, PesoG: 3203, GPDG: 75.3, ConsumoAcumG: 5106, CA: 1.594},
	{Dia: 49, PesoG: 3900, GPDG: 78.7, ConsumoAcumG: 6798, CA: 1.743},
}

// linhagens mapeia o nome da linhagem para seus dados de benchmark.
var linhagens = map[string][]BenchmarkEntry{
	"Cobb 500": Cobb500,
	"Ross 308": Ross308,
}

// GetBenchmarkData retorna os dados de benchmark para uma linhagem.
func GetBenchmarkData(linhagem string) []BenchmarkEntry {
	data, ok := linhagens[linhagem]
	if !ok {
		return nil
	}
	return data
}

// GetPesoPadrao retorna o peso padrao interpolado para uma linhagem em um dia especifico.
// Se o dia exato nao existe nos dados, interpola linearmente entre os dois pontos mais proximos.
func GetPesoPadrao(linhagem string, dia int) *float64 {
	data := GetBenchmarkData(linhagem)
	if data == nil {
		return nil
	}

	// Verificar se o dia esta nos dados exatos
	for _, entry := range data {
		if entry.Dia == dia {
			return &entry.PesoG
		}
	}

	// Interpolar linearmente
	var lower, upper *BenchmarkEntry
	for i := range data {
		if data[i].Dia < dia {
			lower = &data[i]
		}
		if data[i].Dia > dia && upper == nil {
			upper = &data[i]
		}
	}

	if lower == nil || upper == nil {
		// Dia fora do range dos dados
		if dia > data[len(data)-1].Dia {
			// Extrapolar a partir dos ultimos dois pontos
			n := len(data)
			if n >= 2 {
				gpdUltimo := (data[n-1].PesoG - data[n-2].PesoG) / float64(data[n-1].Dia-data[n-2].Dia)
				peso := data[n-1].PesoG + gpdUltimo*float64(dia-data[n-1].Dia)
				return &peso
			}
		}
		return nil
	}

	// Interpolacao linear
	fator := float64(dia-lower.Dia) / float64(upper.Dia-lower.Dia)
	peso := lower.PesoG + fator*(upper.PesoG-lower.PesoG)
	peso = math.Round(peso*100) / 100
	return &peso
}

// GetConsumoAcumPadrao retorna o consumo acumulado padrao interpolado para uma linhagem em um dia.
func GetConsumoAcumPadrao(linhagem string, dia int) *float64 {
	data := GetBenchmarkData(linhagem)
	if data == nil {
		return nil
	}

	for _, entry := range data {
		if entry.Dia == dia {
			return &entry.ConsumoAcumG
		}
	}

	var lower, upper *BenchmarkEntry
	for i := range data {
		if data[i].Dia < dia {
			lower = &data[i]
		}
		if data[i].Dia > dia && upper == nil {
			upper = &data[i]
		}
	}

	if lower == nil || upper == nil {
		return nil
	}

	fator := float64(dia-lower.Dia) / float64(upper.Dia-lower.Dia)
	consumo := lower.ConsumoAcumG + fator*(upper.ConsumoAcumG-lower.ConsumoAcumG)
	consumo = math.Round(consumo*100) / 100
	return &consumo
}

// GetCAPadrao retorna a conversao alimentar padrao interpolada para uma linhagem em um dia.
func GetCAPadrao(linhagem string, dia int) *float64 {
	data := GetBenchmarkData(linhagem)
	if data == nil {
		return nil
	}

	for _, entry := range data {
		if entry.Dia == dia {
			return &entry.CA
		}
	}

	var lower, upper *BenchmarkEntry
	for i := range data {
		if data[i].Dia < dia {
			lower = &data[i]
		}
		if data[i].Dia > dia && upper == nil {
			upper = &data[i]
		}
	}

	if lower == nil || upper == nil {
		return nil
	}

	fator := float64(dia-lower.Dia) / float64(upper.Dia-lower.Dia)
	ca := lower.CA + fator*(upper.CA-lower.CA)
	ca = math.Round(ca*1000) / 1000
	return &ca
}

// ListLinhagens retorna a lista de linhagens disponiveis.
func ListLinhagens() []string {
	result := make([]string, 0, len(linhagens))
	for k := range linhagens {
		result = append(result, k)
	}
	return result
}
