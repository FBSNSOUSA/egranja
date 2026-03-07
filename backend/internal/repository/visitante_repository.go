package repository

import (
	"errors"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrVisitanteNotFound = errors.New("visitante nao encontrado")
)

// VisitanteRepository gerencia operacoes de persistencia de visitantes.
type VisitanteRepository struct {
	db *gorm.DB
}

// NewVisitanteRepository cria uma nova instancia de VisitanteRepository.
func NewVisitanteRepository(db *gorm.DB) *VisitanteRepository {
	return &VisitanteRepository{db: db}
}

// Create cria um novo registro de visitante.
func (r *VisitanteRepository) Create(visitante *model.Visitante) error {
	return r.db.Create(visitante).Error
}

// FindByID busca um visitante pelo ID.
func (r *VisitanteRepository) FindByID(id uuid.UUID) (*model.Visitante, error) {
	var visitante model.Visitante
	result := r.db.Where("id = ?", id).First(&visitante)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrVisitanteNotFound
		}
		return nil, result.Error
	}
	return &visitante, nil
}

// FindByGranja busca visitantes de uma granja com paginacao.
func (r *VisitanteRepository) FindByGranja(granjaID uuid.UUID, page, perPage int) ([]model.Visitante, int64, error) {
	var visitantes []model.Visitante
	var total int64

	query := r.db.Model(&model.Visitante{}).Where("granja_id = ?", granjaID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Order("data_entrada DESC").
		Offset(offset).
		Limit(perPage).
		Find(&visitantes)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return visitantes, total, nil
}

// RegistrarSaida registra a saida de um visitante.
func (r *VisitanteRepository) RegistrarSaida(id uuid.UUID) error {
	now := time.Now()
	result := r.db.Model(&model.Visitante{}).Where("id = ?", id).Update("data_saida", now)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return ErrVisitanteNotFound
	}
	return nil
}
