package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"gorm.io/gorm"
)

// TipoRacaoRepository gerencia operacoes de persistencia de tipos de racao.
type TipoRacaoRepository struct {
	db *gorm.DB
}

// NewTipoRacaoRepository cria uma nova instancia de TipoRacaoRepository.
func NewTipoRacaoRepository(db *gorm.DB) *TipoRacaoRepository {
	return &TipoRacaoRepository{db: db}
}

// FindAll busca todos os tipos de racao ordenados por ordem.
func (r *TipoRacaoRepository) FindAll() ([]model.TipoRacao, error) {
	var tipos []model.TipoRacao
	result := r.db.Order("ordem ASC").Find(&tipos)
	if result.Error != nil {
		return nil, result.Error
	}
	return tipos, nil
}
