package repository

import (
	"errors"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrGalpaoNotFound = errors.New("galpao nao encontrado")
)

// GalpaoRepository gerencia operacoes de persistencia de galpoes.
type GalpaoRepository struct {
	db *gorm.DB
}

// NewGalpaoRepository cria uma nova instancia de GalpaoRepository.
func NewGalpaoRepository(db *gorm.DB) *GalpaoRepository {
	return &GalpaoRepository{db: db}
}

// Create cria um novo galpao.
func (r *GalpaoRepository) Create(galpao *model.Galpao) error {
	return r.db.Create(galpao).Error
}

// FindByID busca um galpao pelo ID.
func (r *GalpaoRepository) FindByID(id uuid.UUID) (*model.Galpao, error) {
	var galpao model.Galpao
	result := r.db.Where("id = ?", id).First(&galpao)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrGalpaoNotFound
		}
		return nil, result.Error
	}
	return &galpao, nil
}

// Update atualiza um galpao existente.
func (r *GalpaoRepository) Update(galpao *model.Galpao) error {
	return r.db.Save(galpao).Error
}

// FindByUsuario busca galpoes de um usuario.
func (r *GalpaoRepository) FindByUsuario(usuarioID uuid.UUID) ([]model.Galpao, error) {
	var galpaos []model.Galpao
	result := r.db.
		Where("usuario_id = ?", usuarioID).
		Order("nome ASC").
		Find(&galpaos)
	if result.Error != nil {
		return nil, result.Error
	}
	return galpaos, nil
}

// FindAcessiveis busca galpoes do usuario (proprios + de granjas colaboradas).
func (r *GalpaoRepository) FindAcessiveis(usuarioID uuid.UUID, granjaIDsColaboradas []uuid.UUID) ([]model.Galpao, error) {
	var galpaos []model.Galpao
	query := r.db.Where("usuario_id = ?", usuarioID)
	if len(granjaIDsColaboradas) > 0 {
		query = r.db.Where("usuario_id = ? OR granja_id IN ?", usuarioID, granjaIDsColaboradas)
	}
	result := query.Order("nome ASC").Find(&galpaos)
	if result.Error != nil {
		return nil, result.Error
	}
	return galpaos, nil
}

// FindByGranja busca galpoes de uma granja.
func (r *GalpaoRepository) FindByGranja(granjaID uuid.UUID) ([]model.Galpao, error) {
	var galpaos []model.Galpao
	result := r.db.
		Where("granja_id = ?", granjaID).
		Order("nome ASC").
		Find(&galpaos)
	if result.Error != nil {
		return nil, result.Error
	}
	return galpaos, nil
}
