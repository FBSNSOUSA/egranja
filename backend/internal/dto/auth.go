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

// RegisterRequest representa o payload de registro de novo usuario.
type RegisterRequest struct {
	Nome     string `json:"nome" validate:"required,min=2,max=200" example:"Jose da Silva"`
	Email    string `json:"email" validate:"required,email,max=200" example:"jose@exemplo.com"`
	Telefone string `json:"telefone" validate:"required,min=8,max=20" example:"(11) 99999-9999"`
	Senha    string `json:"senha" validate:"required,min=6" example:"senha123"`
	Tipo     string `json:"tipo" validate:"required,oneof=produtor tecnico" example:"produtor"`
}

// RegisterResponse representa a resposta de registro com dados do usuario criado.
type RegisterResponse struct {
	Usuario UsuarioInfo `json:"usuario"`
	Message string      `json:"message"`
}

// ForgotPasswordRequest representa o payload para solicitar reset de senha.
type ForgotPasswordRequest struct {
	Email string `json:"email" validate:"required,email" example:"jose@exemplo.com"`
}

// ForgotPasswordResponse representa a resposta do pedido de reset de senha.
type ForgotPasswordResponse struct {
	Message string `json:"message"`
}

// UpdateProfileRequest representa o payload de atualizacao de perfil.
type UpdateProfileRequest struct {
	Nome     string `json:"nome" validate:"omitempty,min=2,max=200"`
	Email    string `json:"email" validate:"omitempty,email,max=200"`
	Telefone string `json:"telefone" validate:"omitempty,min=8,max=20"`
	FotoURL  string `json:"foto_url" validate:"omitempty,max=500"`
}

// ProfileResponse representa os dados do perfil do usuario.
type ProfileResponse struct {
	ID       uuid.UUID `json:"id"`
	Nome     string    `json:"nome"`
	Email    string    `json:"email"`
	Telefone string    `json:"telefone"`
	FotoURL  string    `json:"foto_url"`
	Tipo     string    `json:"tipo"`
	Login    string    `json:"login"`
}
