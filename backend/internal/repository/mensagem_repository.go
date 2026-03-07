package repository

import (
	"errors"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrMensagemNotFound = errors.New("mensagem nao encontrada")
)

// MensagemRepository gerencia operacoes de persistencia de mensagens.
type MensagemRepository struct {
	db *gorm.DB
}

// NewMensagemRepository cria uma nova instancia de MensagemRepository.
func NewMensagemRepository(db *gorm.DB) *MensagemRepository {
	return &MensagemRepository{db: db}
}

// Create cria uma nova mensagem.
func (r *MensagemRepository) Create(mensagem *model.Mensagem) error {
	return r.db.Create(mensagem).Error
}

// FindByID busca uma mensagem pelo ID.
func (r *MensagemRepository) FindByID(id uuid.UUID) (*model.Mensagem, error) {
	var mensagem model.Mensagem
	result := r.db.Preload("Remetente").Where("id = ?", id).First(&mensagem)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrMensagemNotFound
		}
		return nil, result.Error
	}
	return &mensagem, nil
}

// FindByLote busca mensagens de um lote com paginacao.
func (r *MensagemRepository) FindByLote(loteID uuid.UUID, page, perPage int) ([]model.Mensagem, int64, error) {
	var mensagens []model.Mensagem
	var total int64

	query := r.db.Model(&model.Mensagem{}).Where("lote_id = ?", loteID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Preload("Remetente").
		Order("created_at DESC").
		Offset(offset).
		Limit(perPage).
		Find(&mensagens)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return mensagens, total, nil
}

// MarcarLida marca uma mensagem como lida.
func (r *MensagemRepository) MarcarLida(id uuid.UUID) error {
	result := r.db.Model(&model.Mensagem{}).Where("id = ?", id).Update("lida", true)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return ErrMensagemNotFound
	}
	return nil
}

// ContarNaoLidas conta mensagens nao lidas de um lote para um usuario.
func (r *MensagemRepository) ContarNaoLidas(loteID uuid.UUID, usuarioID uuid.UUID) (int64, error) {
	var count int64
	result := r.db.Model(&model.Mensagem{}).
		Where("lote_id = ? AND remetente_id != ? AND lida = false", loteID, usuarioID).
		Count(&count)
	return count, result.Error
}
