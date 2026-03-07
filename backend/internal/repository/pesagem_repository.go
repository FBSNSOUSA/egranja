package repository

import (
	"errors"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrPesagemNotFound = errors.New("pesagem nao encontrada")
)

// PesagemRepository gerencia operacoes de persistencia de pesagens.
type PesagemRepository struct {
	db *gorm.DB
}

// NewPesagemRepository cria uma nova instancia de PesagemRepository.
func NewPesagemRepository(db *gorm.DB) *PesagemRepository {
	return &PesagemRepository{db: db}
}

// Create cria uma nova pesagem com seus items em uma transacao.
func (r *PesagemRepository) Create(pesagem *model.Pesagem) error {
	return r.db.Transaction(func(tx *gorm.DB) error {
		if err := tx.Create(pesagem).Error; err != nil {
			return err
		}
		for i := range pesagem.Items {
			pesagem.Items[i].PesagemID = pesagem.ID
			if err := tx.Create(&pesagem.Items[i]).Error; err != nil {
				return err
			}
		}
		return nil
	})
}

// FindByID busca uma pesagem pelo ID com seus items.
func (r *PesagemRepository) FindByID(id uuid.UUID) (*model.Pesagem, error) {
	var pesagem model.Pesagem
	result := r.db.Preload("Items").Where("id = ?", id).First(&pesagem)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrPesagemNotFound
		}
		return nil, result.Error
	}
	return &pesagem, nil
}

// FindByLote busca pesagens de um lote com paginacao.
func (r *PesagemRepository) FindByLote(loteID uuid.UUID, page, perPage int) ([]model.Pesagem, int64, error) {
	var pesagens []model.Pesagem
	var total int64

	query := r.db.Model(&model.Pesagem{}).Where("lote_id = ?", loteID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Preload("Items").
		Order("data DESC").
		Offset(offset).
		Limit(perPage).
		Find(&pesagens)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return pesagens, total, nil
}
