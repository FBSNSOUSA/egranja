package repository

import (
	"errors"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrMortalidadeNotFound = errors.New("registro de mortalidade nao encontrado")
)

// MortalidadeRepository gerencia operacoes de persistencia de mortalidade.
type MortalidadeRepository struct {
	db *gorm.DB
}

// NewMortalidadeRepository cria uma nova instancia de MortalidadeRepository.
func NewMortalidadeRepository(db *gorm.DB) *MortalidadeRepository {
	return &MortalidadeRepository{db: db}
}

// Create cria um novo registro de mortalidade.
func (r *MortalidadeRepository) Create(mortalidade *model.Mortalidade) error {
	return r.db.Create(mortalidade).Error
}

// FindByID busca um registro de mortalidade pelo ID.
func (r *MortalidadeRepository) FindByID(id uuid.UUID) (*model.Mortalidade, error) {
	var mortalidade model.Mortalidade
	result := r.db.Where("id = ?", id).First(&mortalidade)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrMortalidadeNotFound
		}
		return nil, result.Error
	}
	return &mortalidade, nil
}

// FindByLote busca registros de mortalidade de um lote com paginacao e filtro por data.
func (r *MortalidadeRepository) FindByLote(loteID uuid.UUID, dataInicio, dataFim *time.Time, page, perPage int) ([]model.Mortalidade, int64, error) {
	var mortalidades []model.Mortalidade
	var total int64

	query := r.db.Model(&model.Mortalidade{}).Where("lote_id = ?", loteID)

	if dataInicio != nil {
		query = query.Where("data >= ?", *dataInicio)
	}
	if dataFim != nil {
		query = query.Where("data <= ?", *dataFim)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Order("data DESC").
		Offset(offset).
		Limit(perPage).
		Find(&mortalidades)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return mortalidades, total, nil
}

// SumByLote retorna o total de mortalidade de um lote.
func (r *MortalidadeRepository) SumByLote(loteID uuid.UUID) (int, error) {
	var total int64
	result := r.db.Model(&model.Mortalidade{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade), 0)").
		Scan(&total)
	if result.Error != nil {
		return 0, result.Error
	}
	return int(total), nil
}

// SumByLoteData retorna o total de mortalidade em uma data especifica.
func (r *MortalidadeRepository) SumByLoteData(loteID uuid.UUID, data time.Time) (int, error) {
	var total int64
	result := r.db.Model(&model.Mortalidade{}).
		Where("lote_id = ? AND data = ?", loteID, data).
		Select("COALESCE(SUM(quantidade), 0)").
		Scan(&total)
	if result.Error != nil {
		return 0, result.Error
	}
	return int(total), nil
}

// SumByLotePeriodo retorna o total de mortalidade em um periodo.
func (r *MortalidadeRepository) SumByLotePeriodo(loteID uuid.UUID, dataInicio, dataFim time.Time) (int, error) {
	var total int64
	result := r.db.Model(&model.Mortalidade{}).
		Where("lote_id = ? AND data >= ? AND data <= ?", loteID, dataInicio, dataFim).
		Select("COALESCE(SUM(quantidade), 0)").
		Scan(&total)
	if result.Error != nil {
		return 0, result.Error
	}
	return int(total), nil
}
