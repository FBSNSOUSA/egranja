package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// IARepository gerencia operacoes de persistencia de interacoes com IA.
type IARepository struct {
	db *gorm.DB
}

// NewIARepository cria uma nova instancia de IARepository.
func NewIARepository(db *gorm.DB) *IARepository {
	return &IARepository{db: db}
}

// Create cria uma nova interacao com IA.
func (r *IARepository) Create(interacao *model.IAInteracao) error {
	return r.db.Create(interacao).Error
}

// FindByLoteID busca interacoes de IA de um lote com paginacao.
func (r *IARepository) FindByLoteID(loteID uuid.UUID, page, perPage int) ([]model.IAInteracao, int64, error) {
	var interacoes []model.IAInteracao
	var total int64

	query := r.db.Model(&model.IAInteracao{}).Where("lote_id = ?", loteID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Order("created_at DESC").
		Offset(offset).
		Limit(perPage).
		Find(&interacoes)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return interacoes, total, nil
}

// CountByUsuarioHoje conta quantas interacoes um usuario fez hoje.
func (r *IARepository) CountByUsuarioHoje(usuarioID uuid.UUID) (int64, error) {
	var count int64
	result := r.db.Model(&model.IAInteracao{}).
		Where("usuario_id = ? AND created_at >= CURRENT_DATE", usuarioID).
		Count(&count)
	if result.Error != nil {
		return 0, result.Error
	}
	return count, nil
}
