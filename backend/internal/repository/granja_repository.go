package repository

import (
	"errors"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrGranjaNotFound = errors.New("granja nao encontrada")
)

// GranjaRepository gerencia operacoes de persistencia de granjas.
type GranjaRepository struct {
	db *gorm.DB
}

// NewGranjaRepository cria uma nova instancia de GranjaRepository.
func NewGranjaRepository(db *gorm.DB) *GranjaRepository {
	return &GranjaRepository{db: db}
}

// Create cria uma nova granja.
func (r *GranjaRepository) Create(granja *model.Granja) error {
	return r.db.Create(granja).Error
}

// FindByID busca uma granja pelo ID.
func (r *GranjaRepository) FindByID(id uuid.UUID) (*model.Granja, error) {
	var granja model.Granja
	result := r.db.Preload("Galpaos").Where("id = ?", id).First(&granja)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrGranjaNotFound
		}
		return nil, result.Error
	}
	return &granja, nil
}

// Update atualiza uma granja existente.
func (r *GranjaRepository) Update(granja *model.Granja) error {
	return r.db.Save(granja).Error
}

// Delete remove uma granja pelo ID.
func (r *GranjaRepository) Delete(id uuid.UUID) error {
	result := r.db.Delete(&model.Granja{}, "id = ?", id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return ErrGranjaNotFound
	}
	return nil
}

// FindByUsuario busca granjas de um usuario.
func (r *GranjaRepository) FindByUsuario(usuarioID uuid.UUID) ([]model.Granja, error) {
	var granjas []model.Granja
	result := r.db.
		Preload("Galpaos").
		Where("usuario_id = ?", usuarioID).
		Order("nome ASC").
		Find(&granjas)
	if result.Error != nil {
		return nil, result.Error
	}
	return granjas, nil
}

// CountGalpaos conta o numero de galpoes de uma granja.
func (r *GranjaRepository) CountGalpaos(granjaID uuid.UUID) (int64, error) {
	var count int64
	result := r.db.Model(&model.Galpao{}).Where("granja_id = ?", granjaID).Count(&count)
	return count, result.Error
}

// CountLotesAtivos conta o numero de lotes ativos nos galpoes de uma granja.
func (r *GranjaRepository) CountLotesAtivos(granjaID uuid.UUID) (int64, error) {
	var count int64
	result := r.db.Model(&model.Lote{}).
		Joins("JOIN galpaos ON galpaos.id = lotes.galpao_id").
		Where("galpaos.granja_id = ? AND lotes.status = 'ativo'", granjaID).
		Count(&count)
	return count, result.Error
}
