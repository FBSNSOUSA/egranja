package service

import (
	"bytes"
	"encoding/csv"
	"fmt"
	"strconv"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"go.uber.org/zap"
)

// RelatorioService gerencia a geracao de relatorios.
type RelatorioService struct {
	loteRepo        *repository.LoteRepository
	mortalidadeRepo *repository.MortalidadeRepository
	pesagemRepo     *repository.PesagemRepository
	feedRepo        *repository.FeedRepository
	waterRepo       *repository.WaterRepository
	custoRepo       *repository.CustoRepository
	remuneracaoRepo *repository.RemuneracaoRepository
	indicadores     *IndicadoresService
	logger          *zap.Logger
}

// NewRelatorioService cria uma nova instancia de RelatorioService.
func NewRelatorioService(
	loteRepo *repository.LoteRepository,
	mortalidadeRepo *repository.MortalidadeRepository,
	pesagemRepo *repository.PesagemRepository,
	feedRepo *repository.FeedRepository,
	waterRepo *repository.WaterRepository,
	custoRepo *repository.CustoRepository,
	remuneracaoRepo *repository.RemuneracaoRepository,
	indicadores *IndicadoresService,
	logger *zap.Logger,
) *RelatorioService {
	return &RelatorioService{
		loteRepo:        loteRepo,
		mortalidadeRepo: mortalidadeRepo,
		pesagemRepo:     pesagemRepo,
		feedRepo:        feedRepo,
		waterRepo:       waterRepo,
		custoRepo:       custoRepo,
		remuneracaoRepo: remuneracaoRepo,
		indicadores:     indicadores,
		logger:          logger,
	}
}

// FechamentoData contem os dados do relatorio de fechamento.
type FechamentoData struct {
	Lote         *model.Lote
	DiasDeVida   int
	AvesVivas    int
	Mortalidade  int
	MortPct      float64
	PesoMedio    *float64
	ConsumoRacao float64
	ConsumoAgua  float64
	ICA          *float64
	IEP          *float64
	GPD          *float64
	CustoTotal   float64
	Receita      float64
	Resultado    float64
}

// GerarFechamento gera os dados do relatorio de fechamento de lote.
func (s *RelatorioService) GerarFechamento(lote *model.Lote) (*FechamentoData, error) {
	data := &FechamentoData{
		Lote:       lote,
		DiasDeVida: lote.DiasDeVida(),
	}

	// Indicadores
	indicadores, err := s.indicadores.Calcular(lote)
	if err != nil {
		s.logger.Error("Erro ao calcular indicadores para fechamento", zap.Error(err))
		return nil, err
	}

	data.AvesVivas = indicadores.AvesVivas
	data.Mortalidade = indicadores.MortalidadeTotal
	data.MortPct = indicadores.MortalidadePct
	data.PesoMedio = indicadores.UltimoPesoMedio
	data.ICA = indicadores.ICA
	data.IEP = indicadores.IEP
	data.GPD = indicadores.GPD

	if indicadores.ConsumoTotalRacaoKg != nil {
		data.ConsumoRacao = *indicadores.ConsumoTotalRacaoKg
	}

	// Agua
	consumoAgua, err := s.waterRepo.ConsumoTotal(lote.ID)
	if err == nil {
		data.ConsumoAgua = consumoAgua
	}

	// Financeiro
	custoTotal, err := s.custoRepo.TotalByLote(lote.ID)
	if err == nil {
		data.CustoTotal = custoTotal
	}

	receita, err := s.remuneracaoRepo.TotalByLote(lote.ID)
	if err == nil {
		data.Receita = receita
	}

	data.Resultado = data.Receita - data.CustoTotal

	return data, nil
}

// GerarRelatorioPDF gera o relatorio de fechamento em formato PDF.
// Retorna os bytes do PDF gerado.
func (s *RelatorioService) GerarRelatorioPDF(lote *model.Lote) ([]byte, error) {
	data, err := s.GerarFechamento(lote)
	if err != nil {
		return nil, err
	}

	// Gerar PDF simples em texto (a integracao completa com gofpdf seria feita em producao)
	var buf bytes.Buffer

	buf.WriteString("RELATORIO DE FECHAMENTO DE LOTE - eGranja\n")
	buf.WriteString("==========================================\n\n")
	buf.WriteString(fmt.Sprintf("Galpao: %s\n", lote.Galpao.Nome))
	buf.WriteString(fmt.Sprintf("Data Alojamento: %s\n", lote.DataAlojamento.Format("02/01/2006")))
	if lote.DataFinalizacao != nil {
		buf.WriteString(fmt.Sprintf("Data Finalizacao: %s\n", lote.DataFinalizacao.Format("02/01/2006")))
	}
	buf.WriteString(fmt.Sprintf("Dias de Vida: %d\n", data.DiasDeVida))
	buf.WriteString(fmt.Sprintf("Aves Alojadas: %d\n", lote.Quantidade))
	buf.WriteString(fmt.Sprintf("Aves Vivas: %d\n", data.AvesVivas))
	buf.WriteString(fmt.Sprintf("Mortalidade: %d (%.2f%%)\n", data.Mortalidade, data.MortPct))

	if data.PesoMedio != nil {
		buf.WriteString(fmt.Sprintf("Peso Medio: %.0f g\n", *data.PesoMedio))
	}
	if data.GPD != nil {
		buf.WriteString(fmt.Sprintf("GPD: %.1f g/dia\n", *data.GPD))
	}
	if data.ICA != nil {
		buf.WriteString(fmt.Sprintf("ICA: %.3f\n", *data.ICA))
	}
	if data.IEP != nil {
		buf.WriteString(fmt.Sprintf("IEP: %.1f\n", *data.IEP))
	}

	buf.WriteString(fmt.Sprintf("\nConsumo Racao: %.1f kg\n", data.ConsumoRacao))
	buf.WriteString(fmt.Sprintf("Consumo Agua: %.1f L\n", data.ConsumoAgua))

	buf.WriteString(fmt.Sprintf("\nCusto Total: R$ %.2f\n", data.CustoTotal))
	buf.WriteString(fmt.Sprintf("Receita: R$ %.2f\n", data.Receita))
	buf.WriteString(fmt.Sprintf("Resultado: R$ %.2f\n", data.Resultado))

	return buf.Bytes(), nil
}

// ExportarCSV exporta os dados brutos do lote em formato CSV.
func (s *RelatorioService) ExportarCSV(lote *model.Lote) ([]byte, error) {
	var buf bytes.Buffer
	w := csv.NewWriter(&buf)

	// Cabecalho geral
	_ = w.Write([]string{"# LOTE", lote.ID.String()})
	_ = w.Write([]string{"# GALPAO", lote.Galpao.Nome})
	_ = w.Write([]string{"# DATA ALOJAMENTO", lote.DataAlojamento.Format("2006-01-02")})
	_ = w.Write([]string{"# QUANTIDADE", strconv.Itoa(lote.Quantidade)})
	_ = w.Write([]string{})

	// Pesagens
	_ = w.Write([]string{"PESAGENS"})
	_ = w.Write([]string{"Data", "Quantidade", "Peso Total (g)", "Peso Medio (g)"})
	pesagens, _, err := s.pesagemRepo.FindByLote(lote.ID, 1, 1000)
	if err == nil {
		for _, p := range pesagens {
			_ = w.Write([]string{
				p.Data.Format("2006-01-02"),
				strconv.Itoa(p.QuantidadeTotal),
				fmt.Sprintf("%.3f", p.PesoTotal),
				fmt.Sprintf("%.3f", p.PesoMedio),
			})
		}
	}
	_ = w.Write([]string{})

	// Mortalidade
	_ = w.Write([]string{"MORTALIDADE"})
	_ = w.Write([]string{"Data", "Quantidade", "Causa", "Observacao"})
	mortalidades, _, err := s.mortalidadeRepo.FindByLote(lote.ID, nil, nil, 1, 10000)
	if err == nil {
		for _, m := range mortalidades {
			obs := ""
			if m.Observacao != nil {
				obs = *m.Observacao
			}
			_ = w.Write([]string{
				m.Data.Format("2006-01-02"),
				strconv.Itoa(m.Quantidade),
				m.Causa,
				obs,
			})
		}
	}
	_ = w.Write([]string{})

	// Racao - Recebimentos
	_ = w.Write([]string{"RECEBIMENTOS DE RACAO"})
	_ = w.Write([]string{"Data", "Quantidade (kg)", "Fornecedor", "Origem"})
	receipts, _, err := s.feedRepo.FindReceiptsByLote(lote.ID, 1, 10000)
	if err == nil {
		for _, r := range receipts {
			forn := ""
			if r.Fornecedor != nil {
				forn = *r.Fornecedor
			}
			_ = w.Write([]string{
				r.DataRecebimento.Format("2006-01-02"),
				fmt.Sprintf("%.3f", r.QuantidadeKg),
				forn,
				r.Origem,
			})
		}
	}
	_ = w.Write([]string{})

	// Racao - Consumos
	_ = w.Write([]string{"CONSUMO DE RACAO"})
	_ = w.Write([]string{"Data", "Quantidade (kg)"})
	consumptions, _, err := s.feedRepo.FindConsumptionsByLote(lote.ID, 1, 10000)
	if err == nil {
		for _, c := range consumptions {
			_ = w.Write([]string{
				c.Data.Format("2006-01-02"),
				fmt.Sprintf("%.3f", c.QuantidadeKg),
			})
		}
	}
	_ = w.Write([]string{})

	// Agua
	_ = w.Write([]string{"CONSUMO DE AGUA"})
	_ = w.Write([]string{"Data", "Quantidade (L)"})
	waters, _, err := s.waterRepo.FindByLote(lote.ID, 1, 10000)
	if err == nil {
		for _, wc := range waters {
			_ = w.Write([]string{
				wc.Data.Format("2006-01-02"),
				fmt.Sprintf("%.3f", wc.QuantidadeLitros),
			})
		}
	}

	w.Flush()

	if err := w.Error(); err != nil {
		return nil, fmt.Errorf("erro ao gerar CSV: %w", err)
	}

	return buf.Bytes(), nil
}

// GerarComparativo gera dados comparativos entre lotes do mesmo galpao.
type ComparativoLote struct {
	LoteID         string    `json:"lote_id"`
	DataAlojamento time.Time `json:"data_alojamento"`
	DiasDeVida     int       `json:"dias_de_vida"`
	Quantidade     int       `json:"quantidade"`
	Mortalidade    int       `json:"mortalidade"`
	MortPct        float64   `json:"mortalidade_pct"`
	PesoMedio      *float64  `json:"peso_medio,omitempty"`
	ICA            *float64  `json:"ica,omitempty"`
	IEP            *float64  `json:"iep,omitempty"`
	GPD            *float64  `json:"gpd,omitempty"`
}

func (s *RelatorioService) GerarComparativo(lote *model.Lote) ([]ComparativoLote, error) {
	// Buscar lotes do mesmo galpao
	var lotes []model.Lote
	result := s.loteRepo.DB().
		Where("galpao_id = ?", lote.GalpaoID).
		Order("data_alojamento DESC").
		Limit(10).
		Find(&lotes)
	if result.Error != nil {
		return nil, result.Error
	}

	var comparativos []ComparativoLote
	for _, l := range lotes {
		comp := ComparativoLote{
			LoteID:         l.ID.String(),
			DataAlojamento: l.DataAlojamento,
			DiasDeVida:     l.DiasDeVida(),
			Quantidade:     l.Quantidade,
		}

		indicadores, err := s.indicadores.Calcular(&l)
		if err == nil {
			comp.Mortalidade = indicadores.MortalidadeTotal
			comp.MortPct = indicadores.MortalidadePct
			comp.PesoMedio = indicadores.UltimoPesoMedio
			comp.ICA = indicadores.ICA
			comp.IEP = indicadores.IEP
			comp.GPD = indicadores.GPD
		}

		comparativos = append(comparativos, comp)
	}

	return comparativos, nil
}

// ═══════════════════════════════════════════════════════════════════════
// RELATORIO DE PESAGENS
// ═══════════════════════════════════════════════════════════════════════

// PesagemPonto representa um ponto de dados de pesagem para grafico.
type PesagemPonto struct {
	Data      string  `json:"data"`
	DiasVida  int     `json:"dias_vida"`
	PesoMedio float64 `json:"peso_medio"`
	Qtd       int     `json:"quantidade"`
	PesoTotal float64 `json:"peso_total"`
}

// RelatorioPesagens retorna o historico de pesagens de um lote.
func (s *RelatorioService) RelatorioPesagens(lote *model.Lote) ([]PesagemPonto, error) {
	pesagens, _, err := s.pesagemRepo.FindByLote(lote.ID, 1, 10000)
	if err != nil {
		return nil, err
	}

	var pontos []PesagemPonto
	for _, p := range pesagens {
		diasVida := int(p.Data.Sub(lote.DataAlojamento).Hours() / 24)
		if diasVida < 0 {
			diasVida = 0
		}
		pontos = append(pontos, PesagemPonto{
			Data:      p.Data.Format("2006-01-02"),
			DiasVida:  diasVida,
			PesoMedio: p.PesoMedio,
			Qtd:       p.QuantidadeTotal,
			PesoTotal: p.PesoTotal,
		})
	}

	return pontos, nil
}

// ═══════════════════════════════════════════════════════════════════════
// RELATORIO DE MORTALIDADE
// ═══════════════════════════════════════════════════════════════════════

// MortalidadePonto representa um ponto de dados de mortalidade para grafico.
type MortalidadePonto struct {
	Data       string  `json:"data"`
	DiasVida   int     `json:"dias_vida"`
	Quantidade int     `json:"quantidade"`
	Acumulado  int     `json:"acumulado"`
	Causa      string  `json:"causa"`
	Pct        float64 `json:"percentual"`
}

// RelatorioMortalidade retorna o historico de mortalidade de um lote.
func (s *RelatorioService) RelatorioMortalidade(lote *model.Lote) ([]MortalidadePonto, error) {
	mortalidades, _, err := s.mortalidadeRepo.FindByLote(lote.ID, nil, nil, 1, 10000)
	if err != nil {
		return nil, err
	}

	var pontos []MortalidadePonto
	acumulado := 0
	for _, m := range mortalidades {
		acumulado += m.Quantidade
		diasVida := int(m.Data.Sub(lote.DataAlojamento).Hours() / 24)
		if diasVida < 0 {
			diasVida = 0
		}
		pct := 0.0
		if lote.Quantidade > 0 {
			pct = float64(acumulado) / float64(lote.Quantidade) * 100
		}
		pontos = append(pontos, MortalidadePonto{
			Data:       m.Data.Format("2006-01-02"),
			DiasVida:   diasVida,
			Quantidade: m.Quantidade,
			Acumulado:  acumulado,
			Causa:      m.Causa,
			Pct:        pct,
		})
	}

	return pontos, nil
}

// ═══════════════════════════════════════════════════════════════════════
// RELATORIO DE CONVERSAO ALIMENTAR
// ═══════════════════════════════════════════════════════════════════════

// ConversaoAlimentarData contem os dados de conversao alimentar.
type ConversaoAlimentarData struct {
	ConsumoTotalKg float64  `json:"consumo_total_kg"`
	PesoMedio      *float64 `json:"peso_medio"`
	PesoInicialG   float64  `json:"peso_inicial_g"`
	GanhoPesoG     *float64 `json:"ganho_peso_g"`
	ICA            *float64 `json:"ica"`
	GPD            *float64 `json:"gpd"`
	DiasDeVida     int      `json:"dias_de_vida"`
	AvesVivas      int      `json:"aves_vivas"`
}

// RelatorioConversaoAlimentar retorna os dados de conversao alimentar.
func (s *RelatorioService) RelatorioConversaoAlimentar(lote *model.Lote) (*ConversaoAlimentarData, error) {
	indicadores, err := s.indicadores.Calcular(lote)
	if err != nil {
		return nil, err
	}

	data := &ConversaoAlimentarData{
		PesoInicialG: lote.PesoInicialG,
		DiasDeVida:   lote.DiasDeVida(),
		AvesVivas:    indicadores.AvesVivas,
		PesoMedio:    indicadores.UltimoPesoMedio,
		ICA:          indicadores.ICA,
		GPD:          indicadores.GPD,
	}

	if indicadores.ConsumoTotalRacaoKg != nil {
		data.ConsumoTotalKg = *indicadores.ConsumoTotalRacaoKg
	}

	if indicadores.UltimoPesoMedio != nil {
		ganho := *indicadores.UltimoPesoMedio - lote.PesoInicialG
		data.GanhoPesoG = &ganho
	}

	return data, nil
}

// ═══════════════════════════════════════════════════════════════════════
// RELATORIO DE CONSUMO (RACAO + AGUA)
// ═══════════════════════════════════════════════════════════════════════

// ConsumoPonto representa um ponto de dados de consumo diario.
type ConsumoPonto struct {
	Data     string  `json:"data"`
	DiasVida int     `json:"dias_vida"`
	RacaoKg  float64 `json:"racao_kg"`
	AguaL    float64 `json:"agua_l"`
}

// ConsumoResumo contem o resumo de consumo.
type ConsumoResumo struct {
	TotalRacaoKg float64        `json:"total_racao_kg"`
	TotalAguaL   float64        `json:"total_agua_l"`
	Pontos       []ConsumoPonto `json:"pontos"`
}

// RelatorioConsumo retorna o historico de consumo de racao e agua.
func (s *RelatorioService) RelatorioConsumo(lote *model.Lote) (*ConsumoResumo, error) {
	// Buscar consumos de racao
	consumosRacao, _, err := s.feedRepo.FindConsumptionsByLote(lote.ID, 1, 10000)
	if err != nil {
		return nil, err
	}

	// Buscar consumos de agua
	consumosAgua, _, err := s.waterRepo.FindByLote(lote.ID, 1, 10000)
	if err != nil {
		return nil, err
	}

	// Indexar por data
	racaoPorData := make(map[string]float64)
	aguaPorData := make(map[string]float64)
	datasSet := make(map[string]bool)

	var totalRacao, totalAgua float64

	for _, c := range consumosRacao {
		d := c.Data.Format("2006-01-02")
		racaoPorData[d] += c.QuantidadeKg
		totalRacao += c.QuantidadeKg
		datasSet[d] = true
	}

	for _, w := range consumosAgua {
		d := w.Data.Format("2006-01-02")
		aguaPorData[d] += w.QuantidadeLitros
		totalAgua += w.QuantidadeLitros
		datasSet[d] = true
	}

	// Ordenar datas
	var datas []string
	for d := range datasSet {
		datas = append(datas, d)
	}
	// Sort datas
	for i := 0; i < len(datas); i++ {
		for j := i + 1; j < len(datas); j++ {
			if datas[i] > datas[j] {
				datas[i], datas[j] = datas[j], datas[i]
			}
		}
	}

	var pontos []ConsumoPonto
	for _, d := range datas {
		dt, _ := time.Parse("2006-01-02", d)
		diasVida := int(dt.Sub(lote.DataAlojamento).Hours() / 24)
		if diasVida < 0 {
			diasVida = 0
		}
		pontos = append(pontos, ConsumoPonto{
			Data:     d,
			DiasVida: diasVida,
			RacaoKg:  racaoPorData[d],
			AguaL:    aguaPorData[d],
		})
	}

	return &ConsumoResumo{
		TotalRacaoKg: totalRacao,
		TotalAguaL:   totalAgua,
		Pontos:       pontos,
	}, nil
}
