package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// VacinacaoRepository gerencia operacoes de persistencia de vacinacoes.
type VacinacaoRepository struct {
	db *gorm.DB
}

// NewVacinacaoRepository cria uma nova instancia de VacinacaoRepository.
func NewVacinacaoRepository(db *gorm.DB) *VacinacaoRepository {
	return &VacinacaoRepository{db: db}
}

// Create cria um novo registro de vacinacao.
func (r *VacinacaoRepository) Create(vacinacao *model.Vacinacao) error {
	return r.db.Create(vacinacao).Error
}

// FindByLote busca vacinacoes de um lote.
func (r *VacinacaoRepository) FindByLote(loteID uuid.UUID) ([]model.Vacinacao, error) {
	var vacinacoes []model.Vacinacao
	result := r.db.Where("lote_id = ?", loteID).Order("data DESC").Find(&vacinacoes)
	if result.Error != nil {
		return nil, result.Error
	}
	return vacinacoes, nil
}
