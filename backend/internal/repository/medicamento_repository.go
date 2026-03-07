package repository

import (
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// MedicamentoRepository gerencia operacoes de persistencia de medicamentos.
type MedicamentoRepository struct {
	db *gorm.DB
}

// NewMedicamentoRepository cria uma nova instancia de MedicamentoRepository.
func NewMedicamentoRepository(db *gorm.DB) *MedicamentoRepository {
	return &MedicamentoRepository{db: db}
}

// Create cria um novo registro de medicamento.
func (r *MedicamentoRepository) Create(medicamento *model.Medicamento) error {
	return r.db.Create(medicamento).Error
}

// FindByLote busca medicamentos de um lote.
func (r *MedicamentoRepository) FindByLote(loteID uuid.UUID) ([]model.Medicamento, error) {
	var medicamentos []model.Medicamento
	result := r.db.Where("lote_id = ?", loteID).Order("data_inicio DESC").Find(&medicamentos)
	if result.Error != nil {
		return nil, result.Error
	}
	return medicamentos, nil
}

// MedicamentosEmCarencia retorna medicamentos cujo periodo de carencia ainda nao expirou.
func (r *MedicamentoRepository) MedicamentosEmCarencia(loteID uuid.UUID) ([]model.Medicamento, error) {
	var medicamentos []model.Medicamento
	now := time.Now()
	result := r.db.Where(
		"lote_id = ? AND periodo_carencia_dias > 0 AND (data_fim IS NULL OR (data_fim + (periodo_carencia_dias || ' days')::interval) > ?)",
		loteID, now,
	).Find(&medicamentos)
	if result.Error != nil {
		return nil, result.Error
	}
	return medicamentos, nil
}
