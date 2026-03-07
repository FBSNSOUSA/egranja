package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// RastreabilidadeRepository gerencia operacoes de persistencia da cadeia de rastreabilidade.
type RastreabilidadeRepository struct {
	db *gorm.DB
}

// NewRastreabilidadeRepository cria uma nova instancia de RastreabilidadeRepository.
func NewRastreabilidadeRepository(db *gorm.DB) *RastreabilidadeRepository {
	return &RastreabilidadeRepository{db: db}
}

// Create cria um novo elo na cadeia de rastreabilidade.
func (r *RastreabilidadeRepository) Create(chain *model.RastreabilidadeChain) error {
	return r.db.Create(chain).Error
}

// FindByLote busca todos os elos da cadeia de um lote.
func (r *RastreabilidadeRepository) FindByLote(loteID uuid.UUID) ([]model.RastreabilidadeChain, error) {
	var chains []model.RastreabilidadeChain
	result := r.db.Where("lote_id = ?", loteID).Order("created_at ASC").Find(&chains)
	if result.Error != nil {
		return nil, result.Error
	}
	return chains, nil
}

// FindUltimoHash retorna o hash do ultimo elo da cadeia de um lote.
func (r *RastreabilidadeRepository) FindUltimoHash(loteID uuid.UUID) (*string, error) {
	var chain model.RastreabilidadeChain
	result := r.db.Where("lote_id = ?", loteID).Order("created_at DESC").First(&chain)
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, result.Error
	}
	return &chain.HashAtual, nil
}
