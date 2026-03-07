package dto

import "github.com/google/uuid"

// LoginRequest representa o payload de login.
type LoginRequest struct {
	Login string `json:"login" validate:"required,min=3,max=100" example:"jose.silva"`
	Senha string `json:"senha" validate:"required,min=6" example:"senha123"`
}

// LoginResponse representa a resposta de login com tokens JWT.
type LoginResponse struct {
	AccessToken  string      `json:"access_token"`
	RefreshToken string      `json:"refresh_token"`
	TokenType    string      `json:"token_type"`
	ExpiresIn    int64       `json:"expires_in"` // segundos ate expirar o access token
	Usuario      UsuarioInfo `json:"usuario"`
}

// UsuarioInfo representa informacoes basicas do usuario na resposta de login.
type UsuarioInfo struct {
	ID   uuid.UUID `json:"id"`
	Nome string    `json:"nome"`
	Tipo string    `json:"tipo"`
}

// RefreshRequest representa o payload de refresh de token.
type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" validate:"required"`
}

// RefreshResponse representa a resposta do refresh de token.
type RefreshResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	TokenType    string `json:"token_type"`
	ExpiresIn    int64  `json:"expires_in"`
}
