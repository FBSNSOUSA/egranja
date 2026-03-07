package service

import (
	"fmt"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// AlertaPrioridade define os niveis de prioridade dos alertas.
type AlertaPrioridade string

const (
	PrioridadeCritica AlertaPrioridade = "CRITICA"
	PrioridadeAlta    AlertaPrioridade = "ALTA"
	PrioridadeMedia   AlertaPrioridade = "MEDIA"
)

// Alerta representa um alerta gerado automaticamente pelo sistema.
type Alerta struct {
	Tipo       string           `json:"tipo"`
	Condicao   string           `json:"condicao"`
	Prioridade AlertaPrioridade `json:"prioridade"`
	Mensagem   string           `json:"mensagem"`
	LoteID     uuid.UUID        `json:"lote_id"`
	GalpaoNome string           `json:"galpao_nome,omitempty"`
	Valor      *float64         `json:"valor,omitempty"`
	Limite     *float64         `json:"limite,omitempty"`
	DiasDeVida int              `json:"dias_de_vida"`
}

// AlertaService gerencia a verificacao de alertas automaticos.
type AlertaService struct {
	loteRepo       *repository.LoteRepository
	mortalidadeRepo *repository.MortalidadeRepository
	pesagemRepo    *repository.PesagemRepository
	waterRepo      *repository.WaterRepository
	feedRepo       *repository.FeedRepository
	checklistRepo  *repository.ChecklistRepository
	indicadores    *IndicadoresService
	usuarioRepo    *repository.UsuarioRepository
	logger         *zap.Logger
}

// NewAlertaService cria uma nova instancia de AlertaService.
func NewAlertaService(
	loteRepo *repository.LoteRepository,
	mortalidadeRepo *repository.MortalidadeRepository,
	pesagemRepo *repository.PesagemRepository,
	waterRepo *repository.WaterRepository,
	feedRepo *repository.FeedRepository,
	checklistRepo *repository.ChecklistRepository,
	indicadores *IndicadoresService,
	usuarioRepo *repository.UsuarioRepository,
	logger *zap.Logger,
) *AlertaService {
	return &AlertaService{
		loteRepo:        loteRepo,
		mortalidadeRepo: mortalidadeRepo,
		pesagemRepo:     pesagemRepo,
		waterRepo:       waterRepo,
		feedRepo:        feedRepo,
		checklistRepo:   checklistRepo,
		indicadores:     indicadores,
		usuarioRepo:     usuarioRepo,
		logger:          logger,
	}
}

// VerificarAlertas verifica todas as condicoes de alerta para um lote.
// Os alertas sao calculados em tempo real a partir dos dados do banco.
func (s *AlertaService) VerificarAlertas(lote *model.Lote) []Alerta {
	var alertas []Alerta
	diasDeVida := lote.DiasDeVida()

	// 1. Mortalidade alta no dia (> 0.5% das aves vivas)
	s.verificarMortalidadeDiaria(lote, diasDeVida, &alertas)

	// 2. Mortalidade acumulada alta (> 3% do lote)
	s.verificarMortalidadeAcumulada(lote, diasDeVida, &alertas)

	// 3 e 4. Peso abaixo do padrao (< 90% benchmark = ALTA, < 80% = CRITICA)
	s.verificarPeso(lote, diasDeVida, &alertas)

	// 5. Queda consumo de agua (> 15% vs dia anterior)
	s.verificarConsumoAgua(lote, diasDeVida, &alertas)

	// 6. Relacao agua/racao anormal (fora de 1.6-2.0)
	s.verificarRelacaoAguaRacao(lote, diasDeVida, &alertas)

	// 7. Racao acabando (estoque < 2 dias)
	s.verificarEstoqueRacao(lote, diasDeVida, &alertas)

	// 8. Pesagem nao registrada (> 8 dias)
	s.verificarPesagemAtrasada(lote, diasDeVida, &alertas)

	// 9. Checklist nao completado (ate 20h do dia)
	s.verificarChecklistPendente(lote, diasDeVida, &alertas)

	// 10. Lote proximo ao abate (< 5 dias)
	s.verificarProximoAbate(lote, diasDeVida, &alertas)

	return alertas
}

// VerificarAlertasTodosLotes verifica alertas de todos os lotes de um usuario.
// Para produtores: seus proprios lotes ativos.
// Para tecnicos: lotes dos produtores vinculados.
func (s *AlertaService) VerificarAlertasTodosLotes(userID uuid.UUID, userTipo string) ([]Alerta, error) {
	var lotes []model.Lote
	var err error

	if userTipo == "tecnico" {
		// Buscar produtores vinculados
		produtores, err := s.usuarioRepo.FindProdutoresByTecnicoID(userID)
		if err != nil {
			s.logger.Error("Erro ao buscar produtores do tecnico", zap.Error(err))
			return nil, err
		}

		var produtorIDs []uuid.UUID
		for _, p := range produtores {
			produtorIDs = append(produtorIDs, p.ID)
		}

		if len(produtorIDs) == 0 {
			return []Alerta{}, nil
		}

		lotes, err = s.loteRepo.FindAtivosByUsuarios(produtorIDs)
		if err != nil {
			return nil, err
		}
	} else {
		// Produtor: buscar seus lotes ativos
		lotes, err = s.loteRepo.FindAtivos(userID)
		if err != nil {
			return nil, err
		}
	}

	var todosAlertas []Alerta
	for i := range lotes {
		alertas := s.VerificarAlertas(&lotes[i])
		todosAlertas = append(todosAlertas, alertas...)
	}

	return todosAlertas, nil
}

// verificarMortalidadeDiaria verifica se a mortalidade do dia excede 0.5% das aves vivas.
func (s *AlertaService) verificarMortalidadeDiaria(lote *model.Lote, diasDeVida int, alertas *[]Alerta) {
	hoje := time.Now().Truncate(24 * time.Hour)
	mortalidadeHoje, err := s.mortalidadeRepo.SumByLoteData(lote.ID, hoje)
	if err != nil {
		s.logger.Error("Erro ao verificar mortalidade diaria", zap.Error(err))
		return
	}

	if mortalidadeHoje == 0 {
		return
	}

	// Calcular aves vivas (quantidade - mortalidade acumulada antes de hoje)
	mortalidadeTotal, err := s.mortalidadeRepo.SumByLote(lote.ID)
	if err != nil {
		return
	}
	avesVivas := lote.Quantidade - mortalidadeTotal + mortalidadeHoje // aves vivas no inicio do dia

	if avesVivas <= 0 {
		return
	}

	percentual := float64(mortalidadeHoje) / float64(avesVivas) * 100
	limite := 0.5

	if percentual > limite {
		*alertas = append(*alertas, Alerta{
			Tipo:       "mortalidade_diaria",
			Condicao:   fmt.Sprintf("Mortalidade do dia: %.2f%% (> %.1f%%)", percentual, limite),
			Prioridade: PrioridadeCritica,
			Mensagem:   fmt.Sprintf("Mortalidade alta no dia: %d aves (%.2f%%). Verificar urgentemente.", mortalidadeHoje, percentual),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      &percentual,
			Limite:     &limite,
			DiasDeVida: diasDeVida,
		})
	}
}

// verificarMortalidadeAcumulada verifica se a mortalidade acumulada excede 3%.
func (s *AlertaService) verificarMortalidadeAcumulada(lote *model.Lote, diasDeVida int, alertas *[]Alerta) {
	mortalidadeTotal, err := s.mortalidadeRepo.SumByLote(lote.ID)
	if err != nil {
		s.logger.Error("Erro ao verificar mortalidade acumulada", zap.Error(err))
		return
	}

	if mortalidadeTotal == 0 || lote.Quantidade == 0 {
		return
	}

	percentual := float64(mortalidadeTotal) / float64(lote.Quantidade) * 100
	limite := 3.0

	if percentual > limite {
		*alertas = append(*alertas, Alerta{
			Tipo:       "mortalidade_acumulada",
			Condicao:   fmt.Sprintf("Mortalidade acumulada: %.2f%% (> %.1f%%)", percentual, limite),
			Prioridade: PrioridadeAlta,
			Mensagem:   fmt.Sprintf("Mortalidade acumulada acima de 3%%: %d aves (%.2f%%).", mortalidadeTotal, percentual),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      &percentual,
			Limite:     &limite,
			DiasDeVida: diasDeVida,
		})
	}
}

// verificarPeso verifica se o peso esta abaixo do benchmark.
// < 90% = ALTA, < 80% = CRITICA.
func (s *AlertaService) verificarPeso(lote *model.Lote, diasDeVida int, alertas *[]Alerta) {
	indicadores, err := s.indicadores.Calcular(lote)
	if err != nil {
		s.logger.Error("Erro ao calcular indicadores para alerta de peso", zap.Error(err))
		return
	}

	if indicadores.DesvioPesoPct == nil {
		return
	}

	desvioPct := *indicadores.DesvioPesoPct

	// < 80% do benchmark = desvio < -20% = CRITICA
	if desvioPct < -20 {
		valor := 100 + desvioPct // percentual do benchmark
		limite := 80.0
		*alertas = append(*alertas, Alerta{
			Tipo:       "peso_muito_abaixo",
			Condicao:   fmt.Sprintf("Peso a %.1f%% do benchmark (< 80%%)", valor),
			Prioridade: PrioridadeCritica,
			Mensagem:   fmt.Sprintf("Peso muito abaixo do padrao da linhagem (%.1f%% do benchmark). Verificar nutricao e sanidade.", valor),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      &valor,
			Limite:     &limite,
			DiasDeVida: diasDeVida,
		})
	} else if desvioPct < -10 {
		// < 90% do benchmark = desvio < -10% = ALTA
		valor := 100 + desvioPct
		limite := 90.0
		*alertas = append(*alertas, Alerta{
			Tipo:       "peso_abaixo",
			Condicao:   fmt.Sprintf("Peso a %.1f%% do benchmark (< 90%%)", valor),
			Prioridade: PrioridadeAlta,
			Mensagem:   fmt.Sprintf("Peso abaixo do padrao da linhagem (%.1f%% do benchmark). Avaliar manejo nutricional.", valor),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      &valor,
			Limite:     &limite,
			DiasDeVida: diasDeVida,
		})
	}
}

// verificarConsumoAgua verifica se houve queda > 15% no consumo de agua.
func (s *AlertaService) verificarConsumoAgua(lote *model.Lote, diasDeVida int, alertas *[]Alerta) {
	// Buscar os 2 ultimos registros de consumo de agua
	consumos, _, err := s.waterRepo.FindByLote(lote.ID, 1, 2)
	if err != nil || len(consumos) < 2 {
		return
	}

	// consumos[0] = mais recente, consumos[1] = anterior
	consumoAtual := consumos[0].QuantidadeLitros
	consumoAnterior := consumos[1].QuantidadeLitros

	if consumoAnterior <= 0 {
		return
	}

	variacao := (consumoAnterior - consumoAtual) / consumoAnterior * 100
	limite := 15.0

	if variacao > limite {
		*alertas = append(*alertas, Alerta{
			Tipo:       "queda_consumo_agua",
			Condicao:   fmt.Sprintf("Queda de %.1f%% no consumo de agua (> 15%%)", variacao),
			Prioridade: PrioridadeCritica,
			Mensagem:   fmt.Sprintf("Queda de %.1f%% no consumo de agua vs dia anterior (%.0fL -> %.0fL). Verificar bebedouros e saude das aves.", variacao, consumoAnterior, consumoAtual),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      &variacao,
			Limite:     &limite,
			DiasDeVida: diasDeVida,
		})
	}
}

// verificarRelacaoAguaRacao verifica se a relacao agua/racao esta fora de 1.6-2.0.
func (s *AlertaService) verificarRelacaoAguaRacao(lote *model.Lote, diasDeVida int, alertas *[]Alerta) {
	relacao, err := s.waterRepo.RelacaoAguaRacao(lote.ID)
	if err != nil || relacao == nil {
		return
	}

	limiteMin := 1.6
	limiteMax := 2.0

	if *relacao < limiteMin || *relacao > limiteMax {
		*alertas = append(*alertas, Alerta{
			Tipo:       "relacao_agua_racao",
			Condicao:   fmt.Sprintf("Relacao agua/racao: %.2f (fora de %.1f-%.1f)", *relacao, limiteMin, limiteMax),
			Prioridade: PrioridadeMedia,
			Mensagem:   fmt.Sprintf("Relacao agua/racao anormal: %.2f (esperado entre %.1f e %.1f). Pode indicar problema sanitario ou de manejo.", *relacao, limiteMin, limiteMax),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      relacao,
			DiasDeVida: diasDeVida,
		})
	}
}

// verificarEstoqueRacao verifica se o estoque de racao e suficiente para menos de 2 dias.
func (s *AlertaService) verificarEstoqueRacao(lote *model.Lote, diasDeVida int, alertas *[]Alerta) {
	recebido, consumido, err := s.feedRepo.SaldoAtual(lote.ID)
	if err != nil {
		s.logger.Error("Erro ao verificar estoque de racao", zap.Error(err))
		return
	}

	saldo := recebido - consumido
	if saldo <= 0 || diasDeVida == 0 {
		if saldo <= 0 && consumido > 0 {
			// Sem estoque
			zerado := 0.0
			limite := 2.0
			*alertas = append(*alertas, Alerta{
				Tipo:       "racao_acabando",
				Condicao:   "Estoque de racao zerado",
				Prioridade: PrioridadeAlta,
				Mensagem:   "Estoque de racao zerado. Solicitar novo recebimento urgentemente.",
				LoteID:     lote.ID,
				GalpaoNome: lote.Galpao.Nome,
				Valor:      &zerado,
				Limite:     &limite,
				DiasDeVida: diasDeVida,
			})
		}
		return
	}

	// Calcular consumo medio diario
	consumoMedioDiario := consumido / float64(diasDeVida)
	if consumoMedioDiario <= 0 {
		return
	}

	diasEstoque := saldo / consumoMedioDiario
	limite := 2.0

	if diasEstoque < limite {
		*alertas = append(*alertas, Alerta{
			Tipo:       "racao_acabando",
			Condicao:   fmt.Sprintf("Estoque para %.1f dias (< 2 dias)", diasEstoque),
			Prioridade: PrioridadeAlta,
			Mensagem:   fmt.Sprintf("Estoque de racao para %.1f dias (%.0f kg restantes). Solicitar novo recebimento.", diasEstoque, saldo),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      &diasEstoque,
			Limite:     &limite,
			DiasDeVida: diasDeVida,
		})
	}
}

// verificarPesagemAtrasada verifica se a ultima pesagem foi ha mais de 8 dias.
func (s *AlertaService) verificarPesagemAtrasada(lote *model.Lote, diasDeVida int, alertas *[]Alerta) {
	pesagens, _, err := s.pesagemRepo.FindByLote(lote.ID, 1, 1)
	if err != nil {
		s.logger.Error("Erro ao verificar pesagem atrasada", zap.Error(err))
		return
	}

	limite := 8.0

	if len(pesagens) == 0 {
		// Nunca pesou
		if diasDeVida > int(limite) {
			diasSem := float64(diasDeVida)
			*alertas = append(*alertas, Alerta{
				Tipo:       "pesagem_atrasada",
				Condicao:   fmt.Sprintf("Nenhuma pesagem registrada (%d dias de vida)", diasDeVida),
				Prioridade: PrioridadeMedia,
				Mensagem:   fmt.Sprintf("Nenhuma pesagem registrada em %d dias de lote. Realize uma pesagem para acompanhar o desenvolvimento.", diasDeVida),
				LoteID:     lote.ID,
				GalpaoNome: lote.Galpao.Nome,
				Valor:      &diasSem,
				Limite:     &limite,
				DiasDeVida: diasDeVida,
			})
		}
		return
	}

	ultimaPesagem := pesagens[0]
	diasSemPesagem := time.Since(ultimaPesagem.Data).Hours() / 24

	if diasSemPesagem > limite {
		*alertas = append(*alertas, Alerta{
			Tipo:       "pesagem_atrasada",
			Condicao:   fmt.Sprintf("Ultima pesagem ha %.0f dias (> 8 dias)", diasSemPesagem),
			Prioridade: PrioridadeMedia,
			Mensagem:   fmt.Sprintf("Ultima pesagem ha %.0f dias. Realize uma nova pesagem para acompanhar o desenvolvimento do lote.", diasSemPesagem),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      &diasSemPesagem,
			Limite:     &limite,
			DiasDeVida: diasDeVida,
		})
	}
}

// verificarChecklistPendente verifica se o checklist do dia foi completado ate 20h.
func (s *AlertaService) verificarChecklistPendente(lote *model.Lote, diasDeVida int, alertas *[]Alerta) {
	agora := time.Now()

	// Verificar apenas apos 20h
	if agora.Hour() < 20 {
		return
	}

	hoje := agora.Truncate(24 * time.Hour)
	checklist, err := s.checklistRepo.FindByLoteData(lote.ID, hoje)
	if err != nil {
		// Se nao encontrou checklist, e pendente
		*alertas = append(*alertas, Alerta{
			Tipo:       "checklist_pendente",
			Condicao:   "Checklist diario nao preenchido apos 20h",
			Prioridade: PrioridadeMedia,
			Mensagem:   "Checklist diario de manejo nao foi preenchido hoje. Complete o checklist para manter o historico do lote.",
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			DiasDeVida: diasDeVida,
		})
		return
	}

	if !checklist.Completado {
		pct := checklist.PorcentagemConclusao()
		*alertas = append(*alertas, Alerta{
			Tipo:       "checklist_incompleto",
			Condicao:   fmt.Sprintf("Checklist completado %.0f%% apos 20h", pct),
			Prioridade: PrioridadeMedia,
			Mensagem:   fmt.Sprintf("Checklist diario de manejo esta %.0f%% completo. Finalize todos os itens.", pct),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      &pct,
			DiasDeVida: diasDeVida,
		})
	}
}

// verificarProximoAbate verifica se o lote esta a menos de 5 dias do abate.
func (s *AlertaService) verificarProximoAbate(lote *model.Lote, diasDeVida int, alertas *[]Alerta) {
	diasParaAbate := time.Until(lote.DataPrevistaAbate).Hours() / 24

	if diasParaAbate >= 0 && diasParaAbate < 5 {
		limite := 5.0
		*alertas = append(*alertas, Alerta{
			Tipo:       "proximo_abate",
			Condicao:   fmt.Sprintf("Faltam %.0f dias para a data prevista de abate", diasParaAbate),
			Prioridade: PrioridadeMedia,
			Mensagem:   fmt.Sprintf("Lote proximo da data prevista de abate (%.0f dias). Preparar para apanha e verificar jejum alimentar.", diasParaAbate),
			LoteID:     lote.ID,
			GalpaoNome: lote.Galpao.Nome,
			Valor:      &diasParaAbate,
			Limite:     &limite,
			DiasDeVida: diasDeVida,
		})
	}
}
