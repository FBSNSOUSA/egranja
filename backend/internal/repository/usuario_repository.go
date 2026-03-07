package repository

import (
	"errors"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrUsuarioNotFound    = errors.New("usuario nao encontrado")
	ErrUsuarioLoginExists = errors.New("login ja cadastrado")
)

// UsuarioRepository gerencia operacoes de persistencia de usuarios.
type UsuarioRepository struct {
	db *gorm.DB
}

// NewUsuarioRepository cria uma nova instancia de UsuarioRepository.
func NewUsuarioRepository(db *gorm.DB) *UsuarioRepository {
	return &UsuarioRepository{db: db}
}

// FindByLogin busca um usuario pelo login.
func (r *UsuarioRepository) FindByLogin(login string) (*model.Usuario, error) {
	var usuario model.Usuario
	result := r.db.Where("login = ? AND ativo = true", login).First(&usuario)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrUsuarioNotFound
		}
		return nil, result.Error
	}
	return &usuario, nil
}

// FindByID busca um usuario pelo ID.
func (r *UsuarioRepository) FindByID(id uuid.UUID) (*model.Usuario, error) {
	var usuario model.Usuario
	result := r.db.Where("id = ? AND ativo = true", id).First(&usuario)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrUsuarioNotFound
		}
		return nil, result.Error
	}
	return &usuario, nil
}

// Create cria um novo usuario no banco de dados.
func (r *UsuarioRepository) Create(usuario *model.Usuario) error {
	// Verificar se o login ja existe
	var count int64
	r.db.Model(&model.Usuario{}).Where("login = ?", usuario.Login).Count(&count)
	if count > 0 {
		return ErrUsuarioLoginExists
	}

	return r.db.Create(usuario).Error
}

// Update atualiza um usuario existente.
func (r *UsuarioRepository) Update(usuario *model.Usuario) error {
	return r.db.Save(usuario).Error
}

// FindProdutoresByTecnicoID retorna todos os produtores vinculados a um tecnico.
func (r *UsuarioRepository) FindProdutoresByTecnicoID(tecnicoID uuid.UUID) ([]model.Usuario, error) {
	var usuarios []model.Usuario
	result := r.db.
		Joins("JOIN tecnico_produtores ON tecnico_produtores.produtor_id = usuarios.id").
		Where("tecnico_produtores.tecnico_id = ? AND usuarios.ativo = true", tecnicoID).
		Find(&usuarios)
	if result.Error != nil {
		return nil, result.Error
	}
	return usuarios, nil
}
