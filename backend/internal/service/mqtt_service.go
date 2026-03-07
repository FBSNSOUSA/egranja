package service

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	mqtt "github.com/eclipse/paho.mqtt.golang"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// SensorPayload representa o payload JSON recebido de um sensor IoT.
type SensorPayload struct {
	Temperatura   *float64  `json:"temperatura,omitempty"`
	Umidade       *float64  `json:"umidade,omitempty"`
	CO2           *float64  `json:"co2,omitempty"`
	Amonia        *float64  `json:"amonia,omitempty"`
	Luminosidade  *float64  `json:"luminosidade,omitempty"`
	Timestamp     string    `json:"timestamp,omitempty"`
}

// AlertaIoT representa um alerta gerado por leitura IoT fora do range.
type AlertaIoT struct {
	SensorTipo string  `json:"sensor_tipo"`
	Valor      float64 `json:"valor"`
	Limite     string  `json:"limite"`
	Mensagem   string  `json:"mensagem"`
}

// MQTTService gerencia a conexao MQTT para leitura de sensores IoT.
type MQTTService struct {
	client   mqtt.Client
	iotRepo  *repository.IoTRepository
	logger   *zap.Logger
	topicPrefix string
}

// NewMQTTService cria uma nova instancia de MQTTService e conecta ao broker.
func NewMQTTService(broker, user, pass, topicPrefix string, iotRepo *repository.IoTRepository, logger *zap.Logger) *MQTTService {
	svc := &MQTTService{
		iotRepo:     iotRepo,
		logger:      logger,
		topicPrefix: topicPrefix,
	}

	if broker == "" {
		logger.Warn("MQTT_BROKER_URL nao configurado. Servico MQTT desabilitado.")
		return svc
	}

	opts := mqtt.NewClientOptions().
		AddBroker(broker).
		SetClientID(fmt.Sprintf("egranja-backend-%d", time.Now().UnixNano())).
		SetAutoReconnect(true).
		SetConnectRetry(true).
		SetConnectRetryInterval(10 * time.Second).
		SetConnectionLostHandler(func(_ mqtt.Client, err error) {
			logger.Warn("Conexao MQTT perdida", zap.Error(err))
		}).
		SetOnConnectHandler(func(c mqtt.Client) {
			logger.Info("Conectado ao broker MQTT")
			svc.subscribe(c)
		})

	if user != "" {
		opts.SetUsername(user)
		opts.SetPassword(pass)
	}

	client := mqtt.NewClient(opts)
	token := client.Connect()
	if token.WaitTimeout(10 * time.Second) && token.Error() != nil {
		logger.Error("Erro ao conectar ao broker MQTT", zap.Error(token.Error()))
		return svc
	}

	svc.client = client
	logger.Info("Servico MQTT inicializado", zap.String("broker", broker))

	return svc
}

// subscribe inscreve nos topicos de sensores.
func (s *MQTTService) subscribe(c mqtt.Client) {
	topic := s.topicPrefix + "+/+/sensors"
	token := c.Subscribe(topic, 1, s.handleMessage)
	if token.WaitTimeout(5*time.Second) && token.Error() != nil {
		s.logger.Error("Erro ao inscrever no topico MQTT", zap.String("topic", topic), zap.Error(token.Error()))
		return
	}
	s.logger.Info("Inscrito no topico MQTT", zap.String("topic", topic))
}

// handleMessage processa mensagens recebidas dos sensores.
func (s *MQTTService) handleMessage(_ mqtt.Client, msg mqtt.Message) {
	s.logger.Debug("Mensagem MQTT recebida", zap.String("topic", msg.Topic()), zap.ByteString("payload", msg.Payload()))

	// Extrair galpaoID do topico: egranja/{galpaoID}/{sensorType}/sensors
	parts := splitTopic(msg.Topic())
	if len(parts) < 4 {
		s.logger.Warn("Topico MQTT com formato invalido", zap.String("topic", msg.Topic()))
		return
	}

	galpaoIDStr := parts[1]
	galpaoID, err := uuid.Parse(galpaoIDStr)
	if err != nil {
		s.logger.Warn("GalpaoID invalido no topico MQTT", zap.String("galpao_id", galpaoIDStr))
		return
	}

	var payload SensorPayload
	if err := json.Unmarshal(msg.Payload(), &payload); err != nil {
		s.logger.Warn("Payload MQTT invalido", zap.Error(err))
		return
	}

	ts := time.Now()
	if payload.Timestamp != "" {
		if parsed, err := time.Parse(time.RFC3339, payload.Timestamp); err == nil {
			ts = parsed
		}
	}

	// Processar cada sensor presente no payload
	sensores := map[string]*float64{
		"temperatura":  payload.Temperatura,
		"umidade":      payload.Umidade,
		"co2":          payload.CO2,
		"nh3":          payload.Amonia,
		"luminosidade": payload.Luminosidade,
	}

	unidades := map[string]string{
		"temperatura":  "°C",
		"umidade":      "%",
		"co2":          "ppm",
		"nh3":          "ppm",
		"luminosidade": "lux",
	}

	for tipo, valor := range sensores {
		if valor == nil {
			continue
		}

		reading := &model.IotReading{
			GalpaoID:   galpaoID,
			SensorTipo: tipo,
			Valor:      *valor,
			Unidade:    unidades[tipo],
			Timestamp:  ts,
		}

		if err := s.iotRepo.Create(reading); err != nil {
			s.logger.Error("Erro ao salvar leitura IoT", zap.Error(err), zap.String("sensor", tipo))
			continue
		}

		// Verificar alertas
		alertas := s.verificarAlertasSensor(tipo, *valor)
		for _, alerta := range alertas {
			s.logger.Warn("Alerta IoT detectado",
				zap.String("galpao_id", galpaoID.String()),
				zap.String("sensor", alerta.SensorTipo),
				zap.Float64("valor", alerta.Valor),
				zap.String("mensagem", alerta.Mensagem),
			)
		}
	}
}

// verificarAlertasSensor verifica se os valores estao dentro do range ideal.
func (s *MQTTService) verificarAlertasSensor(tipo string, valor float64) []AlertaIoT {
	var alertas []AlertaIoT

	switch tipo {
	case "temperatura":
		if valor < 20 {
			alertas = append(alertas, AlertaIoT{
				SensorTipo: tipo,
				Valor:      valor,
				Limite:     "< 20°C",
				Mensagem:   fmt.Sprintf("Temperatura baixa: %.1f°C (minimo recomendado: 20°C)", valor),
			})
		}
		if valor > 32 {
			alertas = append(alertas, AlertaIoT{
				SensorTipo: tipo,
				Valor:      valor,
				Limite:     "> 32°C",
				Mensagem:   fmt.Sprintf("Temperatura alta: %.1f°C (maximo recomendado: 32°C)", valor),
			})
		}
	case "umidade":
		if valor < 40 {
			alertas = append(alertas, AlertaIoT{
				SensorTipo: tipo,
				Valor:      valor,
				Limite:     "< 40%",
				Mensagem:   fmt.Sprintf("Umidade baixa: %.1f%% (minimo recomendado: 40%%)", valor),
			})
		}
		if valor > 80 {
			alertas = append(alertas, AlertaIoT{
				SensorTipo: tipo,
				Valor:      valor,
				Limite:     "> 80%",
				Mensagem:   fmt.Sprintf("Umidade alta: %.1f%% (maximo recomendado: 80%%)", valor),
			})
		}
	case "co2":
		if valor > 3000 {
			alertas = append(alertas, AlertaIoT{
				SensorTipo: tipo,
				Valor:      valor,
				Limite:     "> 3000 ppm",
				Mensagem:   fmt.Sprintf("CO2 elevado: %.0f ppm (maximo recomendado: 3000 ppm)", valor),
			})
		}
	case "nh3":
		if valor > 20 {
			alertas = append(alertas, AlertaIoT{
				SensorTipo: tipo,
				Valor:      valor,
				Limite:     "> 20 ppm",
				Mensagem:   fmt.Sprintf("Amonia elevada: %.1f ppm (maximo recomendado: 20 ppm)", valor),
			})
		}
	}

	return alertas
}

// Publish envia uma mensagem para um topico MQTT.
func (s *MQTTService) Publish(topic string, payload interface{}) error {
	if s.client == nil {
		return fmt.Errorf("servico MQTT nao esta disponivel")
	}

	data, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("erro ao serializar payload: %w", err)
	}

	token := s.client.Publish(topic, 1, false, data)
	if token.WaitTimeout(5*time.Second) && token.Error() != nil {
		return fmt.Errorf("erro ao publicar mensagem MQTT: %w", token.Error())
	}

	return nil
}

// Close desconecta do broker MQTT.
func (s *MQTTService) Close() {
	if s.client != nil && s.client.IsConnected() {
		s.client.Disconnect(1000)
		s.logger.Info("Servico MQTT encerrado")
	}
}

// IsAvailable verifica se o servico MQTT esta disponivel.
func (s *MQTTService) IsAvailable() bool {
	return s.client != nil && s.client.IsConnected()
}

// splitTopic divide um topico MQTT em partes.
func splitTopic(topic string) []string {
	var parts []string
	current := ""
	for _, c := range topic {
		if c == '/' {
			parts = append(parts, current)
			current = ""
		} else {
			current += string(c)
		}
	}
	if current != "" {
		parts = append(parts, current)
	}
	return parts
}
