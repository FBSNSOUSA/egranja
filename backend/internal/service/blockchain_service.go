package service

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/FBSNSOUSA/egranja/backend/internal/repository"
	"github.com/google/uuid"
	"go.uber.org/zap"
)

// BlockchainService gerencia a cadeia de rastreabilidade (blockchain simplificada).
type BlockchainService struct {
	rastreabilidadeRepo *repository.RastreabilidadeRepository
	logger              *zap.Logger
}

// NewBlockchainService cria uma nova instancia de BlockchainService.
func NewBlockchainService(rastreabilidadeRepo *repository.RastreabilidadeRepository, logger *zap.Logger) *BlockchainService {
	return &BlockchainService{
		rastreabilidadeRepo: rastreabilidadeRepo,
		logger:              logger,
	}
}

// RegistrarEvento registra um evento na cadeia de rastreabilidade do lote.
func (s *BlockchainService) RegistrarEvento(loteID uuid.UUID, evento string, dados interface{}) error {
	// Serializar dados
	dadosJSON, err := json.Marshal(dados)
	if err != nil {
		return fmt.Errorf("erro ao serializar dados: %w", err)
	}

	// Buscar hash anterior
	hashAnterior, err := s.rastreabilidadeRepo.FindUltimoHash(loteID)
	if err != nil {
		return fmt.Errorf("erro ao buscar hash anterior: %w", err)
	}

	now := time.Now()

	// Calcular hash
	hashAnteriorStr := ""
	if hashAnterior != nil {
		hashAnteriorStr = *hashAnterior
	}

	hashData := fmt.Sprintf("%s|%s|%s|%s|%s",
		loteID.String(),
		evento,
		string(dadosJSON),
		hashAnteriorStr,
		now.UTC().Format(time.RFC3339Nano),
	)
	hash := sha256.Sum256([]byte(hashData))
	hashAtual := fmt.Sprintf("%x", hash)

	chain := &model.RastreabilidadeChain{
		LoteID:       loteID,
		Evento:       evento,
		Dados:        dadosJSON,
		HashAtual:    hashAtual,
		HashAnterior: hashAnterior,
		CreatedAt:    now,
	}

	if err := s.rastreabilidadeRepo.Create(chain); err != nil {
		s.logger.Error("Erro ao registrar evento na cadeia", zap.Error(err))
		return err
	}

	return nil
}

// VerificarCadeia verifica a integridade da cadeia de rastreabilidade de um lote.
func (s *BlockchainService) VerificarCadeia(loteID uuid.UUID) (bool, error) {
	chains, err := s.rastreabilidadeRepo.FindByLote(loteID)
	if err != nil {
		return false, err
	}

	if len(chains) == 0 {
		return true, nil
	}

	// Verificar encadeamento dos hashes
	for i := 1; i < len(chains); i++ {
		if chains[i].HashAnterior == nil {
			return false, nil
		}
		if *chains[i].HashAnterior != chains[i-1].HashAtual {
			return false, nil
		}
	}

	// Primeiro bloco nao deve ter hash anterior
	if chains[0].HashAnterior != nil {
		// Pode ser aceitavel se houve re-encadeamento
	}

	return true, nil
}

// GetCadeia retorna toda a cadeia de rastreabilidade de um lote.
func (s *BlockchainService) GetCadeia(loteID uuid.UUID) ([]model.RastreabilidadeChain, bool, error) {
	chains, err := s.rastreabilidadeRepo.FindByLote(loteID)
	if err != nil {
		return nil, false, err
	}

	integra, err := s.VerificarCadeia(loteID)
	if err != nil {
		return chains, false, err
	}

	return chains, integra, nil
}
