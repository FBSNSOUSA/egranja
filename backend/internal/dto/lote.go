package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateLoteRequest representa o payload de criacao de um novo lote.
type CreateLoteRequest struct {
	GalpaoID          uuid.UUID `json:"galpao_id" validate:"required"`
	DataAlojamento    string    `json:"data_alojamento" validate:"required"` // formato: YYYY-MM-DD
	DataPrevistaAbate string    `json:"data_prevista_abate" validate:"required"` // formato: YYYY-MM-DD
	Quantidade        int       `json:"quantidade" validate:"required,gt=0"`
	Tipo              string    `json:"tipo" validate:"required,oneof=Femea Macho Misto"`
	Linhagem          *string   `json:"linhagem,omitempty"`
	PesoInicialG      *float64  `json:"peso_inicial_g,omitempty" validate:"omitempty,gt=0"`
}

// LoteResponse representa a resposta de um lote com dados basicos.
type LoteResponse struct {
	ID                uuid.UUID  `json:"id"`
	UsuarioID         uuid.UUID  `json:"usuario_id"`
	GalpaoID          uuid.UUID  `json:"galpao_id"`
	GalpaoNome        string     `json:"galpao_nome"`
	DataAlojamento    time.Time  `json:"data_alojamento"`
	DataPrevistaAbate time.Time  `json:"data_prevista_abate"`
	Quantidade        int        `json:"quantidade"`
	Tipo              string     `json:"tipo"`
	Linhagem          *string    `json:"linhagem,omitempty"`
	PesoInicialG      float64    `json:"peso_inicial_g"`
	Status            string     `json:"status"`
	DiasDeVida        int        `json:"dias_de_vida"`
	AvesVivas         int        `json:"aves_vivas"`
	UltimoPesoMedio   *float64   `json:"ultimo_peso_medio,omitempty"`
	MortalidadeTotal  int        `json:"mortalidade_total"`
	DataFinalizacao   *time.Time `json:"data_finalizacao,omitempty"`
	CreatedAt         time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`
}

// LoteIndicadoresResponse representa os indicadores zootecnicos do lote.
type LoteIndicadoresResponse struct {
	LoteID           uuid.UUID  `json:"lote_id"`
	DiasDeVida       int        `json:"dias_de_vida"`
	AvesVivas        int        `json:"aves_vivas"`
	AvesAlojadas     int        `json:"aves_alojadas"`
	MortalidadeTotal int        `json:"mortalidade_total"`
	MortalidadePct   float64    `json:"mortalidade_pct"`
	Viabilidade      float64    `json:"viabilidade"`

	// Peso
	UltimoPesoMedio  *float64 `json:"ultimo_peso_medio,omitempty"`
	PesoPadraoG      *float64 `json:"peso_padrao_g,omitempty"`
	DesvioPesoPct    *float64 `json:"desvio_peso_pct,omitempty"`

	// Indices zootecnicos
	GPD              *float64 `json:"gpd,omitempty"`              // Ganho de peso diario (g/dia)
	ICA              *float64 `json:"ica,omitempty"`              // Indice de conversao alimentar
	IEA              *float64 `json:"iea,omitempty"`              // Indice de eficiencia alimentar
	IEP              *float64 `json:"iep,omitempty"`              // Indice de eficiencia produtiva
	ClassificacaoIEP *string  `json:"classificacao_iep,omitempty"` // Ruim, Regular, Bom, Excelente

	// Racao
	ConsumoTotalRacaoKg  *float64 `json:"consumo_total_racao_kg,omitempty"`
	RecebidoTotalRacaoKg *float64 `json:"recebido_total_racao_kg,omitempty"`
	SaldoRacaoKg         *float64 `json:"saldo_racao_kg,omitempty"`
	DiasEstoqueRacao     *float64 `json:"dias_estoque_racao,omitempty"`
	ConsumoRacaoPorAve   *float64 `json:"consumo_racao_por_ave,omitempty"` // kg/ave

	// Agua
	ConsumoAguaDiaL      *float64 `json:"consumo_agua_dia_l,omitempty"`
	RelacaoAguaRacao     *float64 `json:"relacao_agua_racao,omitempty"`

	// Projecao
	ProjecaoPeso         *ProjecaoPesoDTO `json:"projecao_peso,omitempty"`
}

// ProjecaoPesoDTO representa a projecao de peso do lote.
type ProjecaoPesoDTO struct {
	PesoEstimadoG float64   `json:"peso_estimado_g"`
	DataEstimada  time.Time `json:"data_estimada"`
	GPDG          float64   `json:"gpd_g"`
	Mensagem      string    `json:"mensagem"`
}

// FinalizarLoteRequest representa o payload para finalizar um lote.
type FinalizarLoteRequest struct {
	DataFinalizacao   string   `json:"data_finalizacao" validate:"required"` // formato: YYYY-MM-DD
	AvesEntregues     int      `json:"aves_entregues" validate:"required,gt=0"`
	PesoTotalEntregue float64  `json:"peso_total_entregue" validate:"required,gt=0"`
	SobraRacaoKg      *float64 `json:"sobra_racao_kg,omitempty" validate:"omitempty,gte=0"`
}
