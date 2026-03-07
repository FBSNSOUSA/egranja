package repository

import (
	"errors"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrColaboradorNotFound  = errors.New("colaborador nao encontrado")
	ErrColaboradorDuplicado = errors.New("usuario ja e colaborador desta granja")
	ErrProprietario         = errors.New("usuario e proprietario da granja")
)

// GranjaColaboradorRepository gerencia operacoes de persistencia de colaboradores.
type GranjaColaboradorRepository struct {
	db *gorm.DB
}

// NewGranjaColaboradorRepository cria uma nova instancia.
func NewGranjaColaboradorRepository(db *gorm.DB) *GranjaColaboradorRepository {
	return &GranjaColaboradorRepository{db: db}
}

// Create adiciona um colaborador a uma granja.
func (r *GranjaColaboradorRepository) Create(colab *model.GranjaColaborador) error {
	result := r.db.Create(colab)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrDuplicatedKey) {
			return ErrColaboradorDuplicado
		}
		return result.Error
	}
	return nil
}

// Delete remove um colaborador de uma granja.
func (r *GranjaColaboradorRepository) Delete(granjaID, usuarioID uuid.UUID) error {
	result := r.db.
		Where("granja_id = ? AND usuario_id = ?", granjaID, usuarioID).
		Delete(&model.GranjaColaborador{})
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return ErrColaboradorNotFound
	}
	return nil
}

// FindByGranja retorna todos os colaboradores de uma granja.
func (r *GranjaColaboradorRepository) FindByGranja(granjaID uuid.UUID) ([]model.GranjaColaborador, error) {
	var colabs []model.GranjaColaborador
	result := r.db.
		Preload("Usuario").
		Where("granja_id = ?", granjaID).
		Order("created_at ASC").
		Find(&colabs)
	if result.Error != nil {
		return nil, result.Error
	}
	return colabs, nil
}

// UsuarioTemAcesso verifica se um usuario tem acesso a uma granja como colaborador.
// Retorna a permissao ("editor" ou "visualizador") ou erro se nao tem acesso.
func (r *GranjaColaboradorRepository) UsuarioTemAcesso(granjaID, usuarioID uuid.UUID) (string, error) {
	var colab model.GranjaColaborador
	result := r.db.
		Where("granja_id = ? AND usuario_id = ?", granjaID, usuarioID).
		First(&colab)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return "", ErrColaboradorNotFound
		}
		return "", result.Error
	}
	return colab.Permissao, nil
}

// FindGranjaIDsAcessiveis retorna os IDs de granjas onde o usuario e colaborador.
func (r *GranjaColaboradorRepository) FindGranjaIDsAcessiveis(usuarioID uuid.UUID) ([]uuid.UUID, error) {
	var ids []uuid.UUID
	result := r.db.
		Model(&model.GranjaColaborador{}).
		Where("usuario_id = ?", usuarioID).
		Pluck("granja_id", &ids)
	if result.Error != nil {
		return nil, result.Error
	}
	return ids, nil
}
