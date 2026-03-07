package repository

import (
	"errors"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrCustoNotFound = errors.New("custo nao encontrado")
)

// CustoRepository gerencia operacoes de persistencia de custos.
type CustoRepository struct {
	db *gorm.DB
}

// NewCustoRepository cria uma nova instancia de CustoRepository.
func NewCustoRepository(db *gorm.DB) *CustoRepository {
	return &CustoRepository{db: db}
}

// Create cria um novo registro de custo.
func (r *CustoRepository) Create(custo *model.CustoLote) error {
	return r.db.Create(custo).Error
}

// FindByLote busca custos de um lote.
func (r *CustoRepository) FindByLote(loteID uuid.UUID) ([]model.CustoLote, error) {
	var custos []model.CustoLote
	result := r.db.Where("lote_id = ?", loteID).Order("created_at DESC").Find(&custos)
	if result.Error != nil {
		return nil, result.Error
	}
	return custos, nil
}

// Delete remove um custo pelo ID.
func (r *CustoRepository) Delete(id uuid.UUID) error {
	result := r.db.Delete(&model.CustoLote{}, "id = ?", id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return ErrCustoNotFound
	}
	return nil
}

// FindByID busca um custo pelo ID.
func (r *CustoRepository) FindByID(id uuid.UUID) (*model.CustoLote, error) {
	var custo model.CustoLote
	result := r.db.Where("id = ?", id).First(&custo)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrCustoNotFound
		}
		return nil, result.Error
	}
	return &custo, nil
}

// TotalByLote retorna o total de custos de um lote.
func (r *CustoRepository) TotalByLote(loteID uuid.UUID) (float64, error) {
	var total float64
	result := r.db.Model(&model.CustoLote{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(valor), 0)").
		Scan(&total)
	return total, result.Error
}

// TotalByCategoria retorna o total de custos por categoria de um lote.
type CustoCategoria struct {
	Categoria string  `json:"categoria"`
	Total     float64 `json:"total"`
}

func (r *CustoRepository) TotalByCategoria(loteID uuid.UUID) ([]CustoCategoria, error) {
	var resultados []CustoCategoria
	result := r.db.Model(&model.CustoLote{}).
		Where("lote_id = ?", loteID).
		Select("categoria, COALESCE(SUM(valor), 0) as total").
		Group("categoria").
		Order("total DESC").
		Scan(&resultados)
	if result.Error != nil {
		return nil, result.Error
	}
	return resultados, nil
}
