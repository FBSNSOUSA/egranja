package dto

import (
	"time"

	"github.com/google/uuid"
)

// CreateCustoRequest representa o payload de registro de custo.
type CreateCustoRequest struct {
	Categoria string  `json:"categoria" validate:"required,oneof=mao_de_obra energia aquecimento cama manutencao depreciacao agua outros"`
	Descricao *string `json:"descricao,omitempty" validate:"omitempty,max=200"`
	Valor     float64 `json:"valor" validate:"required"`
	Data      *string `json:"data,omitempty"` // formato: YYYY-MM-DD
}

// CustoResponse representa a resposta de um registro de custo.
type CustoResponse struct {
	ID        uuid.UUID  `json:"id"`
	LoteID    uuid.UUID  `json:"lote_id"`
	Categoria string     `json:"categoria"`
	Descricao *string    `json:"descricao,omitempty"`
	Valor     float64    `json:"valor"`
	Data      *time.Time `json:"data,omitempty"`
	CreatedAt time.Time  `json:"created_at"`
}

// CreateRemuneracaoRequest representa o payload de registro de remuneracao.
type CreateRemuneracaoRequest struct {
	Valor         float64 `json:"valor" validate:"required"`
	Tipo          *string `json:"tipo,omitempty" validate:"omitempty,oneof=por_kg por_ave por_iep outro"`
	DataPagamento *string `json:"data_pagamento,omitempty"` // formato: YYYY-MM-DD
	Observacao    *string `json:"observacao,omitempty"`
}

// RemuneracaoResponse representa a resposta de um registro de remuneracao.
type RemuneracaoResponse struct {
	ID            uuid.UUID  `json:"id"`
	LoteID        uuid.UUID  `json:"lote_id"`
	Valor         float64    `json:"valor"`
	Tipo          *string    `json:"tipo,omitempty"`
	DataPagamento *time.Time `json:"data_pagamento,omitempty"`
	Observacao    *string    `json:"observacao,omitempty"`
	CreatedAt     time.Time  `json:"created_at"`
}

// ResumoFinanceiroResponse representa o resumo financeiro de um lote.
type ResumoFinanceiroResponse struct {
	LoteID            uuid.UUID                `json:"lote_id"`
	CustoTotal        float64                  `json:"custo_total"`
	ReceitaTotal      float64                  `json:"receita_total"`
	ResultadoLiquido  float64                  `json:"resultado_liquido"`
	CustoPorKg        *float64                 `json:"custo_por_kg,omitempty"`
	CustoPorAve       *float64                 `json:"custo_por_ave,omitempty"`
	MargemPorKg       *float64                 `json:"margem_por_kg,omitempty"`
	MargemPorAve      *float64                 `json:"margem_por_ave,omitempty"`
	CustosPorCategoria []CustoCategoriaDTO     `json:"custos_por_categoria"`
}

// CustoCategoriaDTO representa o total de custos por categoria.
type CustoCategoriaDTO struct {
	Categoria string  `json:"categoria"`
	Total     float64 `json:"total"`
}
