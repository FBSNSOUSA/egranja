package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ClimaRepository gerencia operacoes de persistencia de previsoes do tempo.
type ClimaRepository struct {
	db *gorm.DB
}

// NewClimaRepository cria uma nova instancia de ClimaRepository.
func NewClimaRepository(db *gorm.DB) *ClimaRepository {
	return &ClimaRepository{db: db}
}

// Create cria uma nova previsao do tempo.
func (r *ClimaRepository) Create(previsao *model.PrevisaoTempo) error {
	return r.db.Create(previsao).Error
}

// Upsert cria ou atualiza uma previsao do tempo para uma granja e data.
func (r *ClimaRepository) Upsert(previsao *model.PrevisaoTempo) error {
	return r.db.Where("granja_id = ? AND data = ?", previsao.GranjaID, previsao.Data).
		Assign(previsao).
		FirstOrCreate(previsao).Error
}

// FindByGranjaID busca previsoes do tempo de uma granja (proximos 7 dias).
func (r *ClimaRepository) FindByGranjaID(granjaID uuid.UUID) ([]model.PrevisaoTempo, error) {
	var previsoes []model.PrevisaoTempo
	result := r.db.
		Where("granja_id = ? AND data >= CURRENT_DATE", granjaID).
		Order("data ASC").
		Limit(7).
		Find(&previsoes)
	if result.Error != nil {
		return nil, result.Error
	}
	return previsoes, nil
}
