package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// RemuneracaoRepository gerencia operacoes de persistencia de remuneracoes.
type RemuneracaoRepository struct {
	db *gorm.DB
}

// NewRemuneracaoRepository cria uma nova instancia de RemuneracaoRepository.
func NewRemuneracaoRepository(db *gorm.DB) *RemuneracaoRepository {
	return &RemuneracaoRepository{db: db}
}

// Create cria um novo registro de remuneracao.
func (r *RemuneracaoRepository) Create(remuneracao *model.Remuneracao) error {
	return r.db.Create(remuneracao).Error
}

// FindByLote busca remuneracoes de um lote.
func (r *RemuneracaoRepository) FindByLote(loteID uuid.UUID) ([]model.Remuneracao, error) {
	var remuneracoes []model.Remuneracao
	result := r.db.Where("lote_id = ?", loteID).Order("created_at DESC").Find(&remuneracoes)
	if result.Error != nil {
		return nil, result.Error
	}
	return remuneracoes, nil
}

// TotalByLote retorna o total de remuneracoes de um lote.
func (r *RemuneracaoRepository) TotalByLote(loteID uuid.UUID) (float64, error) {
	var total float64
	result := r.db.Model(&model.Remuneracao{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(valor), 0)").
		Scan(&total)
	return total, result.Error
}
