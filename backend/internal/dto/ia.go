package dto

import (
	"time"

	"github.com/google/uuid"
)

// IAConsultaRequest representa o payload de uma consulta a IA.
type IAConsultaRequest struct {
	Pergunta string `json:"pergunta" validate:"required,min=3,max=2000"`
}

// IAConsultaResponse representa a resposta de uma consulta a IA.
type IAConsultaResponse struct {
	Resposta string `json:"resposta"`
	Tokens   int    `json:"tokens"`
}

// IAInteracaoResponse representa uma interacao historica com a IA.
type IAInteracaoResponse struct {
	ID        uuid.UUID `json:"id"`
	Pergunta  string    `json:"pergunta"`
	Resposta  string    `json:"resposta"`
	Tipo      string    `json:"tipo"`
	Modelo    string    `json:"modelo"`
	Tokens    int       `json:"tokens"`
	CreatedAt time.Time `json:"created_at"`
}

// IAAnaliseResponse representa a resposta de uma analise proativa da IA.
type IAAnaliseResponse struct {
	Resposta string `json:"resposta"`
	Tokens   int    `json:"tokens"`
}
