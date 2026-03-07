package service

import (
	"context"
	"fmt"
	"strings"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/genai"
	"gorm.io/gorm"
)

const systemPromptAvicultura = `Você é um zootecnista especialista em avicultura de corte. Analise os dados do lote e dê orientações práticas. Seja direto e objetivo. Cite valores quando relevante.

Suas competências incluem:
- Manejo de frangos de corte (Cobb, Ross, Hubbard)
- Nutrição e conversão alimentar
- Sanidade e biosseguridade
- Ambiência e conforto térmico
- Indicadores zootécnicos (ICA, IEP, GPD, viabilidade)
- Manejo de lote por fase (inicial, crescimento, abate)

Sempre responda em português brasileiro. Baseie suas análises nos dados fornecidos.`

// IAService gerencia a integracao com a IA Gemini para assistencia em avicultura.
type IAService struct {
	client   *genai.Client
	modelo   string
	iaRepo   *repository.IARepository
	loteRepo *repository.LoteRepository
	logger   *zap.Logger
}

// NewIAService cria uma nova instancia de IAService.
func NewIAService(apiKey, modelo string, iaRepo *repository.IARepository, loteRepo *repository.LoteRepository, logger *zap.Logger) *IAService {
	if modelo == "" {
		modelo = "gemini-2.0-flash"
	}

	svc := &IAService{
		modelo:   modelo,
		iaRepo:   iaRepo,
		loteRepo: loteRepo,
		logger:   logger,
	}

	if apiKey == "" {
		logger.Warn("GEMINI_API_KEY nao configurada. Servico de IA desabilitado.")
		return svc
	}

	ctx := context.Background()
	client, err := genai.NewClient(ctx, &genai.ClientConfig{
		APIKey:  apiKey,
		Backend: genai.BackendGeminiAPI,
	})
	if err != nil {
		logger.Error("Erro ao criar client Gemini", zap.Error(err))
		return svc
	}

	svc.client = client
	logger.Info("Servico de IA Gemini inicializado", zap.String("modelo", modelo))

	return svc
}

// Consultar envia uma pergunta ao Gemini com contexto do lote.
func (s *IAService) Consultar(ctx context.Context, pergunta string, contextoLote map[string]interface{}) (string, int, error) {
	if s.client == nil {
		return "", 0, fmt.Errorf("servico de IA nao esta disponivel (API key nao configurada)")
	}

	// Montar contexto do lote como texto
	var ctxParts []string
	ctxParts = append(ctxParts, "Dados do lote:")
	for k, v := range contextoLote {
		ctxParts = append(ctxParts, fmt.Sprintf("- %s: %v", k, v))
	}
	contextoTexto := strings.Join(ctxParts, "\n")

	promptCompleto := fmt.Sprintf("%s\n\nPergunta do produtor: %s", contextoTexto, pergunta)

	contents := []*genai.Content{
		{
			Parts: []*genai.Part{genai.NewPartFromText(promptCompleto)},
			Role:  "user",
		},
	}

	config := &genai.GenerateContentConfig{
		SystemInstruction: &genai.Content{
			Parts: []*genai.Part{genai.NewPartFromText(systemPromptAvicultura)},
		},
	}

	resp, err := s.client.Models.GenerateContent(ctx, s.modelo, contents, config)
	if err != nil {
		return "", 0, fmt.Errorf("erro ao gerar resposta da IA: %w", err)
	}

	if len(resp.Candidates) == 0 || resp.Candidates[0].Content == nil || len(resp.Candidates[0].Content.Parts) == 0 {
		return "", 0, fmt.Errorf("resposta vazia da IA")
	}

	resposta := resp.Candidates[0].Content.Parts[0].Text
	tokens := 0
	if resp.UsageMetadata != nil {
		tokens = int(resp.UsageMetadata.TotalTokenCount)
	}

	return resposta, tokens, nil
}

// AnalisarIndicadores busca indicadores reais do lote e pede analise proativa ao Gemini.
func (s *IAService) AnalisarIndicadores(ctx context.Context, loteID uuid.UUID, db *gorm.DB) (string, int, error) {
	if s.client == nil {
		return "", 0, fmt.Errorf("servico de IA nao esta disponivel")
	}

	// Buscar lote
	lote, err := s.loteRepo.FindByID(loteID)
	if err != nil {
		return "", 0, fmt.Errorf("erro ao buscar lote: %w", err)
	}

	// Montar contexto com indicadores
	contexto := s.buildContextoLote(lote)

	promptAnalise := fmt.Sprintf(`Analise os seguintes indicadores do lote e forneça:
1. Situação geral (bom/regular/atenção/crítico)
2. Pontos positivos
3. Pontos de atenção
4. Recomendações práticas imediatas
5. Previsão para os próximos dias

Dados do lote:
%s`, contexto)

	contents := []*genai.Content{
		{
			Parts: []*genai.Part{genai.NewPartFromText(promptAnalise)},
			Role:  "user",
		},
	}

	config := &genai.GenerateContentConfig{
		SystemInstruction: &genai.Content{
			Parts: []*genai.Part{genai.NewPartFromText(systemPromptAvicultura)},
		},
	}

	resp, err := s.client.Models.GenerateContent(ctx, s.modelo, contents, config)
	if err != nil {
		return "", 0, fmt.Errorf("erro ao gerar analise da IA: %w", err)
	}

	if len(resp.Candidates) == 0 || resp.Candidates[0].Content == nil || len(resp.Candidates[0].Content.Parts) == 0 {
		return "", 0, fmt.Errorf("resposta vazia da IA")
	}

	resposta := resp.Candidates[0].Content.Parts[0].Text
	tokens := 0
	if resp.UsageMetadata != nil {
		tokens = int(resp.UsageMetadata.TotalTokenCount)
	}

	return resposta, tokens, nil
}

// buildContextoLote monta o contexto do lote como mapa para enviar ao Gemini.
func (s *IAService) buildContextoLote(lote *model.Lote) string {
	var parts []string

	parts = append(parts, fmt.Sprintf("- ID: %s", lote.ID))
	parts = append(parts, fmt.Sprintf("- Tipo: %s", lote.Tipo))
	parts = append(parts, fmt.Sprintf("- Quantidade alojada: %d", lote.Quantidade))
	parts = append(parts, fmt.Sprintf("- Data alojamento: %s", lote.DataAlojamento.Format("02/01/2006")))
	parts = append(parts, fmt.Sprintf("- Idade (dias): %d", lote.DiasDeVida()))
	parts = append(parts, fmt.Sprintf("- Status: %s", lote.Status))

	if lote.Linhagem != nil {
		parts = append(parts, fmt.Sprintf("- Linhagem: %s", *lote.Linhagem))
	}

	parts = append(parts, fmt.Sprintf("- Peso inicial (g): %.1f", lote.PesoInicialG))

	// Mortalidade
	mortalidadeTotal, err := s.loteRepo.GetMortalidadeTotal(lote.ID)
	if err == nil {
		parts = append(parts, fmt.Sprintf("- Mortalidade total: %d aves", mortalidadeTotal))
		avesVivas := lote.Quantidade - mortalidadeTotal
		parts = append(parts, fmt.Sprintf("- Aves vivas: %d", avesVivas))
		if lote.Quantidade > 0 {
			mortPct := float64(mortalidadeTotal) / float64(lote.Quantidade) * 100
			parts = append(parts, fmt.Sprintf("- Mortalidade (%%): %.2f%%", mortPct))
		}
	}

	// Ultimo peso
	ultimoPeso, err := s.loteRepo.GetUltimoPesoMedio(lote.ID)
	if err == nil && ultimoPeso != nil {
		parts = append(parts, fmt.Sprintf("- Ultimo peso medio (g): %.1f", *ultimoPeso))
		dias := lote.DiasDeVida()
		if dias > 0 {
			gpd := (*ultimoPeso - lote.PesoInicialG) / float64(dias)
			parts = append(parts, fmt.Sprintf("- GPD (g/dia): %.1f", gpd))
		}
	}

	// Consumo de racao
	consumoRacao, err := s.loteRepo.GetConsumoTotalRacao(lote.ID)
	if err == nil && consumoRacao > 0 {
		parts = append(parts, fmt.Sprintf("- Consumo total racao (kg): %.1f", consumoRacao))
		if ultimoPeso != nil && *ultimoPeso > 0 {
			avesVivas := lote.Quantidade - mortalidadeTotal
			if avesVivas > 0 {
				pesoTotalProd := (*ultimoPeso - lote.PesoInicialG) * float64(avesVivas) / 1000
				if pesoTotalProd > 0 {
					ica := consumoRacao / pesoTotalProd
					parts = append(parts, fmt.Sprintf("- ICA: %.3f", ica))
				}
			}
		}
	}

	// Consumo de agua
	consumoAgua, err := s.loteRepo.GetConsumoTotalAgua(lote.ID)
	if err == nil && consumoAgua > 0 {
		parts = append(parts, fmt.Sprintf("- Consumo total agua (L): %.1f", consumoAgua))
	}

	return strings.Join(parts, "\n")
}

// BuildContextoLoteMap monta o contexto do lote como mapa.
func (s *IAService) BuildContextoLoteMap(lote *model.Lote) map[string]interface{} {
	ctx := map[string]interface{}{
		"tipo":             lote.Tipo,
		"quantidade":       lote.Quantidade,
		"data_alojamento":  lote.DataAlojamento.Format("02/01/2006"),
		"idade_dias":       lote.DiasDeVida(),
		"status":           lote.Status,
		"peso_inicial_g":   lote.PesoInicialG,
	}

	if lote.Linhagem != nil {
		ctx["linhagem"] = *lote.Linhagem
	}

	mortalidadeTotal, err := s.loteRepo.GetMortalidadeTotal(lote.ID)
	if err == nil {
		ctx["mortalidade_total"] = mortalidadeTotal
		ctx["aves_vivas"] = lote.Quantidade - mortalidadeTotal
		if lote.Quantidade > 0 {
			ctx["mortalidade_pct"] = float64(mortalidadeTotal) / float64(lote.Quantidade) * 100
		}
	}

	ultimoPeso, err := s.loteRepo.GetUltimoPesoMedio(lote.ID)
	if err == nil && ultimoPeso != nil {
		ctx["ultimo_peso_medio_g"] = *ultimoPeso
		dias := lote.DiasDeVida()
		if dias > 0 {
			ctx["gpd_g"] = (*ultimoPeso - lote.PesoInicialG) / float64(dias)
		}
	}

	consumoRacao, err := s.loteRepo.GetConsumoTotalRacao(lote.ID)
	if err == nil && consumoRacao > 0 {
		ctx["consumo_total_racao_kg"] = consumoRacao
	}

	return ctx
}

// Close fecha o client Gemini.
func (s *IAService) Close() {
	// O client genai nao possui metodo Close explicitamente necessario,
	// mas mantemos a interface para consistencia.
	s.logger.Info("Servico de IA encerrado")
}

// IsAvailable verifica se o servico de IA esta disponivel.
func (s *IAService) IsAvailable() bool {
	return s.client != nil
}
