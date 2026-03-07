package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateVacinacaoRequest representa o payload de registro de vacinacao.
type CreateVacinacaoRequest struct {
	Data             string  `json:"data" validate:"required"` // formato: YYYY-MM-DD
	Vacina           string  `json:"vacina" validate:"required,max=200"`
	LoteProduto      *string `json:"lote_produto,omitempty" validate:"omitempty,max=100"`
	ViaAdministracao *string `json:"via_administracao,omitempty" validate:"omitempty,max=50"`
	Responsavel      *string `json:"responsavel,omitempty" validate:"omitempty,max=200"`
	Observacao       *string `json:"observacao,omitempty"`
}

// VacinacaoResponse representa a resposta de um registro de vacinacao.
type VacinacaoResponse struct {
	ID               uuid.UUID `json:"id"`
	LoteID           uuid.UUID `json:"lote_id"`
	Data             time.Time `json:"data"`
	Vacina           string    `json:"vacina"`
	LoteProduto      *string   `json:"lote_produto,omitempty"`
	ViaAdministracao *string   `json:"via_administracao,omitempty"`
	Responsavel      *string   `json:"responsavel,omitempty"`
	Observacao       *string   `json:"observacao,omitempty"`
	CreatedAt        time.Time `json:"created_at"`
}

// CreateMedicamentoRequest representa o payload de registro de medicamento.
type CreateMedicamentoRequest struct {
	DataInicio          string  `json:"data_inicio" validate:"required"` // formato: YYYY-MM-DD
	DataFim             *string `json:"data_fim,omitempty"`              // formato: YYYY-MM-DD
	Medicamento         string  `json:"medicamento" validate:"required,max=200"`
	Dosagem             *string `json:"dosagem,omitempty" validate:"omitempty,max=100"`
	Via                 *string `json:"via,omitempty" validate:"omitempty,max=50"`
	PeriodoCarenciaDias *int    `json:"periodo_carencia_dias,omitempty" validate:"omitempty,gte=0"`
	Responsavel         *string `json:"responsavel,omitempty" validate:"omitempty,max=200"`
	Observacao          *string `json:"observacao,omitempty"`
}

// MedicamentoResponse representa a resposta de um registro de medicamento.
type MedicamentoResponse struct {
	ID                  uuid.UUID  `json:"id"`
	LoteID              uuid.UUID  `json:"lote_id"`
	DataInicio          time.Time  `json:"data_inicio"`
	DataFim             *time.Time `json:"data_fim,omitempty"`
	Medicamento         string     `json:"medicamento"`
	Dosagem             *string    `json:"dosagem,omitempty"`
	Via                 *string    `json:"via,omitempty"`
	PeriodoCarenciaDias *int       `json:"periodo_carencia_dias,omitempty"`
	Responsavel         *string    `json:"responsavel,omitempty"`
	Observacao          *string    `json:"observacao,omitempty"`
	EmCarencia          bool       `json:"em_carencia"`
	CreatedAt           time.Time  `json:"created_at"`
}

// CreateVisitanteRequest representa o payload de registro de visitante.
type CreateVisitanteRequest struct {
	Nome              string  `json:"nome" validate:"required,max=200"`
	Documento         *string `json:"documento,omitempty" validate:"omitempty,max=50"`
	Origem            *string `json:"origem,omitempty" validate:"omitempty,max=200"`
	Motivo            *string `json:"motivo,omitempty" validate:"omitempty,max=200"`
	UltimoContatoAves *string `json:"ultimo_contato_aves,omitempty"` // formato: YYYY-MM-DD
	PlacaVeiculo      *string `json:"placa_veiculo,omitempty" validate:"omitempty,max=20"`
	DataEntrada       string  `json:"data_entrada" validate:"required"` // formato: YYYY-MM-DDTHH:MM:SS
	Observacao        *string `json:"observacao,omitempty"`
}

// VisitanteResponse representa a resposta de um registro de visitante.
type VisitanteResponse struct {
	ID                uuid.UUID  `json:"id"`
	GranjaID          uuid.UUID  `json:"granja_id"`
	Nome              string     `json:"nome"`
	Documento         *string    `json:"documento,omitempty"`
	Origem            *string    `json:"origem,omitempty"`
	Motivo            *string    `json:"motivo,omitempty"`
	UltimoContatoAves *time.Time `json:"ultimo_contato_aves,omitempty"`
	PlacaVeiculo      *string    `json:"placa_veiculo,omitempty"`
	DataEntrada       time.Time  `json:"data_entrada"`
	DataSaida         *time.Time `json:"data_saida,omitempty"`
	Observacao        *string    `json:"observacao,omitempty"`
	CreatedAt         time.Time  `json:"created_at"`
}

// GTARequest representa o payload para geracao de GTA digital.
type GTARequest struct {
	Origem             string `json:"origem" validate:"required"`
	Destino            string `json:"destino" validate:"required"`
	Quantidade         int    `json:"quantidade" validate:"required,gt=0"`
	Especie            string `json:"especie" validate:"required"`
	Finalidade         string `json:"finalidade" validate:"required"`
	CertificadoSanitario *string `json:"certificado_sanitario,omitempty"`
}

// RastreabilidadeResponse representa a cadeia de rastreabilidade de um lote.
type RastreabilidadeResponse struct {
	LoteID    uuid.UUID                `json:"lote_id"`
	Cadeia    []RastreabilidadeItemDTO `json:"cadeia"`
	Integra   bool                     `json:"integra"`
}

// RastreabilidadeItemDTO representa um item na cadeia de rastreabilidade.
type RastreabilidadeItemDTO struct {
	ID           uuid.UUID `json:"id"`
	Evento       string    `json:"evento"`
	Dados        interface{} `json:"dados"`
	HashAtual    string    `json:"hash_atual"`
	HashAnterior *string   `json:"hash_anterior,omitempty"`
	CreatedAt    time.Time `json:"created_at"`
}
