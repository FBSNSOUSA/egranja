package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// AmbienciaRepository gerencia operacoes de persistencia de registros ambientais.
type AmbienciaRepository struct {
	db *gorm.DB
}

// NewAmbienciaRepository cria uma nova instancia de AmbienciaRepository.
func NewAmbienciaRepository(db *gorm.DB) *AmbienciaRepository {
	return &AmbienciaRepository{db: db}
}

// Create cria um novo registro ambiental.
func (r *AmbienciaRepository) Create(registro *model.RegistroAmbiental) error {
	return r.db.Create(registro).Error
}

// FindByLote busca registros ambientais de um lote com paginacao.
func (r *AmbienciaRepository) FindByLote(loteID uuid.UUID, page, perPage int) ([]model.RegistroAmbiental, int64, error) {
	var registros []model.RegistroAmbiental
	var total int64

	query := r.db.Model(&model.RegistroAmbiental{}).Where("lote_id = ?", loteID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Order("data DESC").
		Offset(offset).
		Limit(perPage).
		Find(&registros)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return registros, total, nil
}
