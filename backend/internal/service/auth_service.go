package service

import (
	"errors"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/config"
	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

var (
	ErrInvalidCredentials = errors.New("usuario ou senha incorretos")
	ErrInvalidRefreshToken = errors.New("refresh token invalido ou expirado")
)

// AuthService gerencia autenticacao e tokens JWT.
type AuthService struct {
	usuarioRepo *repository.UsuarioRepository
	cfg         *config.Config
	logger      *zap.Logger
}

// NewAuthService cria uma nova instancia de AuthService.
func NewAuthService(usuarioRepo *repository.UsuarioRepository, cfg *config.Config, logger *zap.Logger) *AuthService {
	return &AuthService{
		usuarioRepo: usuarioRepo,
		cfg:         cfg,
		logger:      logger,
	}
}

// Login autentica um usuario e retorna os tokens JWT.
func (s *AuthService) Login(req dto.LoginRequest) (*dto.LoginResponse, error) {
	// Buscar usuario pelo login
	usuario, err := s.usuarioRepo.FindByLogin(req.Login)
	if err != nil {
		if errors.Is(err, repository.ErrUsuarioNotFound) {
			return nil, ErrInvalidCredentials
		}
		s.logger.Error("Erro ao buscar usuario no login", zap.Error(err))
		return nil, err
	}

	// Verificar senha com bcrypt
	if !usuario.CheckPassword(req.Senha) {
		return nil, ErrInvalidCredentials
	}

	// Gerar tokens
	accessToken, err := s.generateAccessToken(usuario.ID, usuario.Tipo)
	if err != nil {
		s.logger.Error("Erro ao gerar access token", zap.Error(err))
		return nil, err
	}

	refreshToken, err := s.generateRefreshToken(usuario.ID, usuario.Tipo)
	if err != nil {
		s.logger.Error("Erro ao gerar refresh token", zap.Error(err))
		return nil, err
	}

	return &dto.LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		TokenType:    "Bearer",
		ExpiresIn:    int64(s.cfg.JWTAccessExpiry.Seconds()),
		Usuario: dto.UsuarioInfo{
			ID:   usuario.ID,
			Nome: usuario.Nome,
			Tipo: usuario.Tipo,
		},
	}, nil
}

// RefreshToken renova o access token usando um refresh token valido.
func (s *AuthService) RefreshToken(req dto.RefreshRequest) (*dto.RefreshResponse, error) {
	// Validar o refresh token
	claims := &middleware.JWTClaims{}
	token, err := jwt.ParseWithClaims(req.RefreshToken, claims, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, jwt.ErrSignatureInvalid
		}
		return []byte(s.cfg.JWTSecret), nil
	})

	if err != nil || !token.Valid {
		return nil, ErrInvalidRefreshToken
	}

	// Verificar se o usuario ainda existe e esta ativo
	usuario, err := s.usuarioRepo.FindByID(claims.UserID)
	if err != nil {
		if errors.Is(err, repository.ErrUsuarioNotFound) {
			return nil, ErrInvalidRefreshToken
		}
		return nil, err
	}

	// Gerar novos tokens
	newAccessToken, err := s.generateAccessToken(usuario.ID, usuario.Tipo)
	if err != nil {
		return nil, err
	}

	newRefreshToken, err := s.generateRefreshToken(usuario.ID, usuario.Tipo)
	if err != nil {
		return nil, err
	}

	return &dto.RefreshResponse{
		AccessToken:  newAccessToken,
		RefreshToken: newRefreshToken,
		TokenType:    "Bearer",
		ExpiresIn:    int64(s.cfg.JWTAccessExpiry.Seconds()),
	}, nil
}

// generateAccessToken gera um access token JWT com expiracao de 24h.
func (s *AuthService) generateAccessToken(userID uuid.UUID, tipo string) (string, error) {
	now := time.Now()
	claims := middleware.JWTClaims{
		UserID: userID,
		Tipo:   tipo,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(s.cfg.JWTAccessExpiry)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "egranja",
			Subject:   userID.String(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.cfg.JWTSecret))
}

// generateRefreshToken gera um refresh token JWT com expiracao de 30 dias.
func (s *AuthService) generateRefreshToken(userID uuid.UUID, tipo string) (string, error) {
	now := time.Now()
	claims := middleware.JWTClaims{
		UserID: userID,
		Tipo:   tipo,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(now.Add(s.cfg.JWTRefreshExpiry)),
			IssuedAt:  jwt.NewNumericDate(now),
			NotBefore: jwt.NewNumericDate(now),
			Issuer:    "egranja-refresh",
			Subject:   userID.String(),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(s.cfg.JWTSecret))
}
