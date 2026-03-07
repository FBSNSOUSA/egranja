package service

import (
	"context"
	"fmt"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"github.com/google/uuid"
	"go.uber.org/zap"
	"google.golang.org/api/option"
)

// NotificacaoService define a interface para envio de notificacoes push.
type NotificacaoService interface {
	// EnviarPush envia uma notificacao push para um usuario.
	EnviarPush(ctx context.Context, userID uuid.UUID, titulo, corpo string, data map[string]string) error

	// EnviarParaTecnico envia um alerta critico ao tecnico vinculado ao lote.
	EnviarParaTecnico(ctx context.Context, loteID uuid.UUID, alerta Alerta) error
}

// FirebaseNotificacaoService implementa NotificacaoService usando Firebase Cloud Messaging.
type FirebaseNotificacaoService struct {
	client *messaging.Client
	logger *zap.Logger
	// getDeviceToken busca o token de dispositivo do usuario no banco.
	// Em producao, isso viria de uma tabela de device tokens.
	getDeviceToken func(userID uuid.UUID) (string, error)
	// getTecnicoByLote busca o tecnico vinculado a um lote.
	getTecnicoByLote func(loteID uuid.UUID) (*uuid.UUID, error)
}

// NewFirebaseNotificacaoService cria uma nova instancia de FirebaseNotificacaoService.
// Se o credentialsFile estiver vazio, retorna um servico no-op que apenas loga.
func NewFirebaseNotificacaoService(credentialsFile string, logger *zap.Logger) NotificacaoService {
	if credentialsFile == "" {
		logger.Warn("Firebase credentials nao configurado. Notificacoes push desabilitadas.")
		return &NoOpNotificacaoService{logger: logger}
	}

	ctx := context.Background()
	app, err := firebase.NewApp(ctx, nil, option.WithCredentialsFile(credentialsFile))
	if err != nil {
		logger.Error("Erro ao inicializar Firebase App", zap.Error(err))
		return &NoOpNotificacaoService{logger: logger}
	}

	client, err := app.Messaging(ctx)
	if err != nil {
		logger.Error("Erro ao inicializar Firebase Messaging", zap.Error(err))
		return &NoOpNotificacaoService{logger: logger}
	}

	logger.Info("Firebase Cloud Messaging inicializado com sucesso")

	return &FirebaseNotificacaoService{
		client: client,
		logger: logger,
	}
}

// EnviarPush envia uma notificacao push via Firebase.
func (s *FirebaseNotificacaoService) EnviarPush(ctx context.Context, userID uuid.UUID, titulo, corpo string, data map[string]string) error {
	if s.getDeviceToken == nil {
		s.logger.Debug("getDeviceToken nao configurado, notificacao ignorada",
			zap.String("user_id", userID.String()),
			zap.String("titulo", titulo),
		)
		return nil
	}

	token, err := s.getDeviceToken(userID)
	if err != nil {
		s.logger.Error("Erro ao buscar device token",
			zap.String("user_id", userID.String()),
			zap.Error(err),
		)
		return err
	}

	if token == "" {
		s.logger.Debug("Device token vazio, notificacao ignorada",
			zap.String("user_id", userID.String()),
		)
		return nil
	}

	message := &messaging.Message{
		Token: token,
		Notification: &messaging.Notification{
			Title: titulo,
			Body:  corpo,
		},
		Data: data,
		Android: &messaging.AndroidConfig{
			Priority: "high",
			Notification: &messaging.AndroidNotification{
				Sound:       "default",
				ChannelID:   "egranja_alertas",
				ClickAction: "FLUTTER_NOTIFICATION_CLICK",
			},
		},
		APNS: &messaging.APNSConfig{
			Payload: &messaging.APNSPayload{
				Aps: &messaging.Aps{
					Sound:    "default",
					Badge:    intPtr(1),
					Category: "ALERTA",
				},
			},
		},
	}

	response, err := s.client.Send(ctx, message)
	if err != nil {
		s.logger.Error("Erro ao enviar notificacao push",
			zap.String("user_id", userID.String()),
			zap.String("titulo", titulo),
			zap.Error(err),
		)
		return err
	}

	s.logger.Info("Notificacao push enviada",
		zap.String("user_id", userID.String()),
		zap.String("titulo", titulo),
		zap.String("response", response),
	)

	return nil
}

// EnviarParaTecnico envia um alerta critico ao tecnico vinculado ao lote.
func (s *FirebaseNotificacaoService) EnviarParaTecnico(ctx context.Context, loteID uuid.UUID, alerta Alerta) error {
	if s.getTecnicoByLote == nil {
		s.logger.Debug("getTecnicoByLote nao configurado, notificacao ao tecnico ignorada")
		return nil
	}

	tecnicoID, err := s.getTecnicoByLote(loteID)
	if err != nil {
		s.logger.Error("Erro ao buscar tecnico do lote", zap.Error(err))
		return err
	}

	if tecnicoID == nil {
		return nil
	}

	titulo := fmt.Sprintf("Alerta %s - %s", string(alerta.Prioridade), alerta.GalpaoNome)
	data := map[string]string{
		"tipo":       alerta.Tipo,
		"prioridade": string(alerta.Prioridade),
		"lote_id":    loteID.String(),
	}

	return s.EnviarPush(ctx, *tecnicoID, titulo, alerta.Mensagem, data)
}

// NoOpNotificacaoService e uma implementacao no-op para quando Firebase nao esta configurado.
type NoOpNotificacaoService struct {
	logger *zap.Logger
}

// EnviarPush loga a notificacao sem enviar.
func (s *NoOpNotificacaoService) EnviarPush(_ context.Context, userID uuid.UUID, titulo, corpo string, _ map[string]string) error {
	s.logger.Debug("Notificacao push (no-op)",
		zap.String("user_id", userID.String()),
		zap.String("titulo", titulo),
		zap.String("corpo", corpo),
	)
	return nil
}

// EnviarParaTecnico loga a notificacao ao tecnico sem enviar.
func (s *NoOpNotificacaoService) EnviarParaTecnico(_ context.Context, loteID uuid.UUID, alerta Alerta) error {
	s.logger.Debug("Notificacao ao tecnico (no-op)",
		zap.String("lote_id", loteID.String()),
		zap.String("tipo", alerta.Tipo),
		zap.String("prioridade", string(alerta.Prioridade)),
	)
	return nil
}

// intPtr retorna um ponteiro para um int.
func intPtr(v int) *int {
	return &v
}
