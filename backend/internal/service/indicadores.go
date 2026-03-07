package service

import (
	"fmt"
	"math"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/benchmark"
	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"go.uber.org/zap"
)

// IndicadoresService calcula os indices zootecnicos de um lote.
type IndicadoresService struct {
	loteRepo *repository.LoteRepository
	logger   *zap.Logger
}

// NewIndicadoresService cria uma nova instancia de IndicadoresService.
func NewIndicadoresService(loteRepo *repository.LoteRepository, logger *zap.Logger) *IndicadoresService {
	return &IndicadoresService{
		loteRepo: loteRepo,
		logger:   logger,
	}
}

// Calcular retorna todos os indicadores zootecnicos de um lote.
func (s *IndicadoresService) Calcular(lote *model.Lote) (*dto.LoteIndicadoresResponse, error) {
	resp := &dto.LoteIndicadoresResponse{
		LoteID:       lote.ID,
		AvesAlojadas: lote.Quantidade,
	}

	// Dias de vida
	resp.DiasDeVida = lote.DiasDeVida()

	// Mortalidade total
	mortalidadeTotal, err := s.loteRepo.GetMortalidadeTotal(lote.ID)
	if err != nil {
		s.logger.Error("Erro ao calcular mortalidade total", zap.Error(err))
		return nil, err
	}
	resp.MortalidadeTotal = mortalidadeTotal

	// Aves vivas
	resp.AvesVivas = lote.Quantidade - mortalidadeTotal

	// Mortalidade percentual
	if lote.Quantidade > 0 {
		resp.MortalidadePct = roundTo(float64(mortalidadeTotal)/float64(lote.Quantidade)*100, 2)
	}

	// Viabilidade
	resp.Viabilidade = roundTo(100.0-resp.MortalidadePct, 2)

	// Ultimo peso medio
	ultimoPesoMedio, err := s.loteRepo.GetUltimoPesoMedio(lote.ID)
	if err != nil {
		s.logger.Error("Erro ao buscar ultimo peso medio", zap.Error(err))
		return nil, err
	}
	resp.UltimoPesoMedio = ultimoPesoMedio

	// Peso padrao da linhagem e desvio
	if lote.Linhagem != nil && ultimoPesoMedio != nil {
		pesoPadrao := benchmark.GetPesoPadrao(*lote.Linhagem, resp.DiasDeVida)
		if pesoPadrao != nil {
			resp.PesoPadraoG = pesoPadrao
			if *pesoPadrao > 0 {
				desvio := roundTo((*ultimoPesoMedio-*pesoPadrao) / *pesoPadrao * 100, 1)
				resp.DesvioPesoPct = &desvio
			}
		}
	}

	// GPD (Ganho de Peso Diario)
	if ultimoPesoMedio != nil && resp.DiasDeVida > 0 {
		gpd := roundTo((*ultimoPesoMedio-lote.PesoInicialG)/float64(resp.DiasDeVida), 1)
		resp.GPD = &gpd
	}

	// Consumo total de racao
	consumoTotalRacao, err := s.loteRepo.GetConsumoTotalRacao(lote.ID)
	if err != nil {
		s.logger.Error("Erro ao calcular consumo total de racao", zap.Error(err))
		return nil, err
	}
	if consumoTotalRacao > 0 {
		resp.ConsumoTotalRacaoKg = &consumoTotalRacao
	}

	// Recebido total de racao
	recebidoTotalRacao, err := s.loteRepo.GetRecebidoTotalRacao(lote.ID)
	if err != nil {
		s.logger.Error("Erro ao calcular recebido total de racao", zap.Error(err))
		return nil, err
	}
	if recebidoTotalRacao > 0 {
		resp.RecebidoTotalRacaoKg = &recebidoTotalRacao
	}

	// Saldo de racao
	saldoRacao := recebidoTotalRacao - consumoTotalRacao
	resp.SaldoRacaoKg = &saldoRacao

	// Dias de estoque de racao (baseado no consumo medio diario)
	if resp.DiasDeVida > 0 && consumoTotalRacao > 0 {
		consumoMedioDiario := consumoTotalRacao / float64(resp.DiasDeVida)
		if consumoMedioDiario > 0 {
			diasEstoque := roundTo(saldoRacao/consumoMedioDiario, 1)
			resp.DiasEstoqueRacao = &diasEstoque
		}
	}

	// Consumo por ave (kg)
	if resp.AvesVivas > 0 && consumoTotalRacao > 0 {
		consumoPorAve := roundTo(consumoTotalRacao/float64(resp.AvesVivas), 3)
		resp.ConsumoRacaoPorAve = &consumoPorAve
	}

	// ICA (Indice de Conversao Alimentar)
	// ICA = Consumo Total Racao (kg) / Peso Total Produzido (kg)
	if ultimoPesoMedio != nil && *ultimoPesoMedio > 0 && consumoTotalRacao > 0 && resp.AvesVivas > 0 {
		pesoTotalProduzido := (*ultimoPesoMedio - lote.PesoInicialG) * float64(resp.AvesVivas) / 1000 // gramas para kg
		if pesoTotalProduzido > 0 {
			ica := roundTo(consumoTotalRacao/pesoTotalProduzido, 3)
			resp.ICA = &ica

			// IEA (Indice de Eficiencia Alimentar) = 1 / ICA
			if ica > 0 {
				iea := roundTo(1.0/ica, 3)
				resp.IEA = &iea
			}
		}
	}

	// IEP (Indice de Eficiencia Produtiva)
	// IEP = (GPD(g) x Viabilidade%) / (CA x 10)
	if resp.GPD != nil && resp.ICA != nil && *resp.ICA > 0 {
		iep := roundTo((*resp.GPD * resp.Viabilidade) / (*resp.ICA * 10), 1)
		resp.IEP = &iep

		// Classificacao do IEP
		classificacao := classificarIEP(iep)
		resp.ClassificacaoIEP = &classificacao
	}

	// Agua - consumo do dia
	consumoAguaDia, err := s.loteRepo.GetConsumoAguaDia(lote.ID)
	if err != nil {
		s.logger.Error("Erro ao buscar consumo de agua do dia", zap.Error(err))
		return nil, err
	}
	resp.ConsumoAguaDiaL = consumoAguaDia

	// Relacao agua/racao
	consumoTotalAgua, err := s.loteRepo.GetConsumoTotalAgua(lote.ID)
	if err != nil {
		s.logger.Error("Erro ao calcular consumo total de agua", zap.Error(err))
		return nil, err
	}
	if consumoTotalAgua > 0 && consumoTotalRacao > 0 {
		relacao := roundTo(consumoTotalAgua/consumoTotalRacao, 2)
		resp.RelacaoAguaRacao = &relacao
	}

	// Projecao de peso
	if resp.GPD != nil && *resp.GPD > 0 && ultimoPesoMedio != nil {
		projecao := s.calcularProjecao(lote, *ultimoPesoMedio, *resp.GPD)
		resp.ProjecaoPeso = projecao
	}

	return resp, nil
}

// calcularProjecao calcula a projecao de peso para a data prevista de abate.
func (s *IndicadoresService) calcularProjecao(lote *model.Lote, pesoAtual, gpdG float64) *dto.ProjecaoPesoDTO {
	now := time.Now()
	diasRestantes := int(lote.DataPrevistaAbate.Sub(now).Hours() / 24)
	if diasRestantes <= 0 {
		return nil
	}

	pesoEstimado := pesoAtual + (gpdG * float64(diasRestantes))

	return &dto.ProjecaoPesoDTO{
		PesoEstimadoG: roundTo(pesoEstimado, 0),
		DataEstimada:  lote.DataPrevistaAbate,
		GPDG:          gpdG,
		Mensagem: fmt.Sprintf(
			"Ao ritmo atual (GPD %.1fg), o lote atingira %.0f g em %d dias (%s)",
			gpdG,
			pesoEstimado,
			diasRestantes,
			lote.DataPrevistaAbate.Format("02/01/2006"),
		),
	}
}

// classificarIEP retorna a classificacao textual do IEP.
func classificarIEP(iep float64) string {
	switch {
	case iep > 400:
		return "Excelente"
	case iep >= 350:
		return "Bom"
	case iep >= 260:
		return "Regular"
	default:
		return "Ruim"
	}
}

// roundTo arredonda um float para n casas decimais.
func roundTo(val float64, places int) float64 {
	p := math.Pow(10, float64(places))
	return math.Round(val*p) / p
}
