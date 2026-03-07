package dto

import (
	"time"

	"github.com/google/uuid"
)

// AddColaboradorRequest representa o payload para adicionar um colaborador a uma granja.
type AddColaboradorRequest struct {
	UsuarioID uuid.UUID `json:"usuario_id" validate:"required"`
	Permissao string    `json:"permissao" validate:"required,oneof=editor visualizador"`
}

// ColaboradorResponse representa a resposta de um colaborador.
type ColaboradorResponse struct {
	ID          uuid.UUID `json:"id"`
	GranjaID    uuid.UUID `json:"granja_id"`
	UsuarioID   uuid.UUID `json:"usuario_id"`
	UsuarioNome string    `json:"usuario_nome"`
	Permissao   string    `json:"permissao"`
	CreatedAt   time.Time `json:"created_at"`
}
