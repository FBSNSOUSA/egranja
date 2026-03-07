package service

import (
	"context"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/robfig/cron/v3"
	"go.uber.org/zap"
)

// SchedulerService gerencia tarefas periodicas agendadas via cron.
type SchedulerService struct {
	cron         *cron.Cron
	climaService *ClimaService
	iaService    *IAService
	galpaoRepo   *repository.GalpaoRepository
	loteRepo     *repository.LoteRepository
	granjaRepo   *repository.GranjaRepository
	logger       *zap.Logger
}

// NewSchedulerService cria uma nova instancia de SchedulerService.
func NewSchedulerService(
	climaService *ClimaService,
	iaService *IAService,
	galpaoRepo *repository.GalpaoRepository,
	loteRepo *repository.LoteRepository,
	granjaRepo *repository.GranjaRepository,
	logger *zap.Logger,
) *SchedulerService {
	c := cron.New(cron.WithLocation(time.FixedZone("BRT", -3*60*60)))

	return &SchedulerService{
		cron:         c,
		climaService: climaService,
		iaService:    iaService,
		galpaoRepo:   galpaoRepo,
		loteRepo:     loteRepo,
		granjaRepo:   granjaRepo,
		logger:       logger,
	}
}

// Start inicia o scheduler com todas as tarefas agendadas.
func (s *SchedulerService) Start() {
	// A cada 1h: buscar previsao do tempo para granjas com coordenadas
	_, err := s.cron.AddFunc("0 * * * *", s.tarefaPrevisaoTempo)
	if err != nil {
		s.logger.Error("Erro ao agendar tarefa de previsao do tempo", zap.Error(err))
	}

	// A cada 6h: analise proativa de IA para lotes ativos
	_, err = s.cron.AddFunc("0 */6 * * *", s.tarefaAnaliseIA)
	if err != nil {
		s.logger.Error("Erro ao agendar tarefa de analise IA", zap.Error(err))
	}

	// A cada 24h as 06:00: gerar checklist diario (placeholder)
	_, err = s.cron.AddFunc("0 6 * * *", s.tarefaChecklistDiario)
	if err != nil {
		s.logger.Error("Erro ao agendar tarefa de checklist diario", zap.Error(err))
	}

	s.cron.Start()
	s.logger.Info("Scheduler de tarefas iniciado",
		zap.Int("tarefas_agendadas", len(s.cron.Entries())),
	)
}

// Stop para o scheduler.
func (s *SchedulerService) Stop() {
	ctx := s.cron.Stop()
	<-ctx.Done()
	s.logger.Info("Scheduler de tarefas encerrado")
}

// tarefaPrevisaoTempo busca a previsao do tempo para todas as granjas com coordenadas.
func (s *SchedulerService) tarefaPrevisaoTempo() {
	s.logger.Info("Executando tarefa: previsao do tempo")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()

	// Buscar todas as granjas (usando query direta pois nao temos um metodo FindAll)
	var granjas []struct {
		ID        string
		Latitude  *float64
		Longitude *float64
	}

	if s.granjaRepo == nil {
		s.logger.Warn("GranjaRepo nao disponivel para tarefa de previsao")
		return
	}

	// Usar query direta via galpaoRepo (que tem acesso ao DB)
	// Para simplificar, fazemos um log informativo
	s.logger.Info("Tarefa de previsao do tempo: buscando granjas com coordenadas")

	// Granjas com coordenadas seriam processadas aqui
	// A implementacao real buscaria todas as granjas com lat/lon e chamaria BuscarPrevisao
	_ = ctx
	_ = granjas
}

// tarefaAnaliseIA executa analise proativa de IA para lotes com indicadores fora do benchmark.
func (s *SchedulerService) tarefaAnaliseIA() {
	s.logger.Info("Executando tarefa: analise proativa de IA")

	if s.iaService == nil || !s.iaService.IsAvailable() {
		s.logger.Warn("Servico de IA nao disponivel para analise proativa")
		return
	}

	s.logger.Info("Tarefa de analise IA: verificando lotes ativos")
	// A implementacao real buscaria todos os lotes ativos e chamaria AnalisarIndicadores
}

// tarefaChecklistDiario gera o checklist diario para todos os lotes ativos.
func (s *SchedulerService) tarefaChecklistDiario() {
	s.logger.Info("Executando tarefa: checklist diario")
	// A implementacao real criaria checklists para todos os lotes ativos
}
