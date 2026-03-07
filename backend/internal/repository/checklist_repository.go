package repository

import (
	"errors"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrChecklistNotFound = errors.New("checklist nao encontrado")
)

// ChecklistRepository gerencia operacoes de persistencia de checklists.
type ChecklistRepository struct {
	db *gorm.DB
}

// NewChecklistRepository cria uma nova instancia de ChecklistRepository.
func NewChecklistRepository(db *gorm.DB) *ChecklistRepository {
	return &ChecklistRepository{db: db}
}

// Create cria um novo checklist.
func (r *ChecklistRepository) Create(checklist *model.Checklist) error {
	return r.db.Create(checklist).Error
}

// Update atualiza um checklist existente.
func (r *ChecklistRepository) Update(checklist *model.Checklist) error {
	return r.db.Save(checklist).Error
}

// FindByLoteData busca um checklist pelo lote e data.
func (r *ChecklistRepository) FindByLoteData(loteID uuid.UUID, data time.Time) (*model.Checklist, error) {
	var checklist model.Checklist
	result := r.db.Where("lote_id = ? AND data = ?", loteID, data).First(&checklist)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrChecklistNotFound
		}
		return nil, result.Error
	}
	return &checklist, nil
}

// FindByLotePeriodo busca checklists de um lote em um periodo.
func (r *ChecklistRepository) FindByLotePeriodo(loteID uuid.UUID, page, perPage int) ([]model.Checklist, int64, error) {
	var checklists []model.Checklist
	var total int64

	query := r.db.Model(&model.Checklist{}).Where("lote_id = ?", loteID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Order("data DESC").
		Offset(offset).
		Limit(perPage).
		Find(&checklists)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return checklists, total, nil
}
