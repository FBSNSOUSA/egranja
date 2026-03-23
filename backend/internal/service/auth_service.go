package service

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/config"
	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

var (
	ErrInvalidCredentials  = errors.New("usuario ou senha incorretos")
	ErrInvalidRefreshToken = errors.New("refresh token invalido ou expirado")
	ErrEmailAlreadyExists  = errors.New("email ja cadastrado")
	ErrLoginAlreadyExists  = errors.New("login ja cadastrado")
	ErrUserNotFound        = errors.New("usuario nao encontrado")
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

// Register cria um novo usuario no sistema.
func (s *AuthService) Register(req dto.RegisterRequest) (*dto.RegisterResponse, error) {
	// Usar email como login
	usuario := &model.Usuario{
		Login:    req.Email,
		Nome:     req.Nome,
		Email:    req.Email,
		Telefone: req.Telefone,
		Tipo:     req.Tipo,
		Ativo:    true,
	}

	// Hashear senha
	if err := usuario.SetPassword(req.Senha, s.cfg.BcryptCost); err != nil {
		s.logger.Error("Erro ao hashear senha no registro", zap.Error(err))
		return nil, err
	}

	// Criar usuario
	if err := s.usuarioRepo.Create(usuario); err != nil {
		if errors.Is(err, repository.ErrUsuarioLoginExists) {
			return nil, ErrEmailAlreadyExists
		}
		s.logger.Error("Erro ao criar usuario no registro", zap.Error(err))
		return nil, err
	}

	return &dto.RegisterResponse{
		Usuario: dto.UsuarioInfo{
			ID:   usuario.ID,
			Nome: usuario.Nome,
			Tipo: usuario.Tipo,
		},
		Message: "Conta criada com sucesso!",
	}, nil
}

// ForgotPassword gera um token de reset de senha e loga (envio de email futuro).
func (s *AuthService) ForgotPassword(req dto.ForgotPasswordRequest) (*dto.ForgotPasswordResponse, error) {
	// Buscar usuario pelo email
	usuario, err := s.usuarioRepo.FindByEmail(req.Email)
	if err != nil {
		if errors.Is(err, repository.ErrUsuarioNotFound) {
			// Nao revelar se o email existe ou nao (seguranca)
			return &dto.ForgotPasswordResponse{
				Message: "Se o email estiver cadastrado, voce recebera instrucoes para redefinir sua senha.",
			}, nil
		}
		s.logger.Error("Erro ao buscar usuario por email", zap.Error(err))
		return nil, err
	}

	// Gerar token de reset
	tokenBytes := make([]byte, 32)
	if _, err := rand.Read(tokenBytes); err != nil {
		s.logger.Error("Erro ao gerar token de reset", zap.Error(err))
		return nil, err
	}
	resetToken := hex.EncodeToString(tokenBytes)
	expiry := time.Now().Add(1 * time.Hour)

	// Salvar token no usuario
	usuario.ResetToken = resetToken
	usuario.ResetTokenExp = &expiry
	if err := s.usuarioRepo.Update(usuario); err != nil {
		s.logger.Error("Erro ao salvar token de reset", zap.Error(err))
		return nil, err
	}

	// Log do token (envio real de email sera configurado via SMTP_* env vars)
	s.logger.Info("Token de reset de senha gerado",
		zap.String("email", req.Email),
		zap.String("reset_token", resetToken),
		zap.Time("expiry", expiry),
	)

	return &dto.ForgotPasswordResponse{
		Message: "Se o email estiver cadastrado, voce recebera instrucoes para redefinir sua senha.",
	}, nil
}

// GetProfile retorna os dados do perfil do usuario.
func (s *AuthService) GetProfile(userID uuid.UUID) (*dto.ProfileResponse, error) {
	usuario, err := s.usuarioRepo.FindByID(userID)
	if err != nil {
		if errors.Is(err, repository.ErrUsuarioNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}

	return &dto.ProfileResponse{
		ID:       usuario.ID,
		Nome:     usuario.Nome,
		Email:    usuario.Email,
		Telefone: usuario.Telefone,
		FotoURL:  usuario.FotoURL,
		Tipo:     usuario.Tipo,
		Login:    usuario.Login,
	}, nil
}

// UpdateProfile atualiza os dados do perfil do usuario.
func (s *AuthService) UpdateProfile(userID uuid.UUID, req dto.UpdateProfileRequest) (*dto.ProfileResponse, error) {
	usuario, err := s.usuarioRepo.FindByID(userID)
	if err != nil {
		if errors.Is(err, repository.ErrUsuarioNotFound) {
			return nil, ErrUserNotFound
		}
		return nil, err
	}

	if req.Nome != "" {
		usuario.Nome = req.Nome
	}
	if req.Email != "" {
		usuario.Email = req.Email
	}
	if req.Telefone != "" {
		usuario.Telefone = req.Telefone
	}
	if req.FotoURL != "" {
		usuario.FotoURL = req.FotoURL
	}

	if err := s.usuarioRepo.Update(usuario); err != nil {
		s.logger.Error("Erro ao atualizar perfil", zap.Error(err))
		return nil, err
	}

	return &dto.ProfileResponse{
		ID:       usuario.ID,
		Nome:     usuario.Nome,
		Email:    usuario.Email,
		Telefone: usuario.Telefone,
		FotoURL:  usuario.FotoURL,
		Tipo:     usuario.Tipo,
		Login:    usuario.Login,
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
