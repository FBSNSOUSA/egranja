package repository

import (
	"errors"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrWhatsappRecipientNotFound = errors.New("destinatario whatsapp nao encontrado")
)

// WhatsappRepository gerencia operacoes de persistencia de WhatsApp.
type WhatsappRepository struct {
	db *gorm.DB
}

// NewWhatsappRepository cria uma nova instancia de WhatsappRepository.
func NewWhatsappRepository(db *gorm.DB) *WhatsappRepository {
	return &WhatsappRepository{db: db}
}

// CreateRecipient cria um novo destinatario de WhatsApp.
func (r *WhatsappRepository) CreateRecipient(recipient *model.WhatsappRecipient) error {
	return r.db.Create(recipient).Error
}

// FindRecipientsByLote busca destinatarios de um lote.
func (r *WhatsappRepository) FindRecipientsByLote(loteID uuid.UUID) ([]model.WhatsappRecipient, error) {
	var recipients []model.WhatsappRecipient
	result := r.db.Where("lote_id = ?", loteID).Order("nome ASC").Find(&recipients)
	if result.Error != nil {
		return nil, result.Error
	}
	return recipients, nil
}

// DeleteRecipient remove um destinatario.
func (r *WhatsappRepository) DeleteRecipient(id uuid.UUID) error {
	result := r.db.Delete(&model.WhatsappRecipient{}, "id = ?", id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return ErrWhatsappRecipientNotFound
	}
	return nil
}

// FindRecipientByID busca um destinatario pelo ID.
func (r *WhatsappRepository) FindRecipientByID(id uuid.UUID) (*model.WhatsappRecipient, error) {
	var recipient model.WhatsappRecipient
	result := r.db.Where("id = ?", id).First(&recipient)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrWhatsappRecipientNotFound
		}
		return nil, result.Error
	}
	return &recipient, nil
}

// CreateSendHistory cria um registro de historico de envio.
func (r *WhatsappRepository) CreateSendHistory(history *model.WhatsappSendHistory) error {
	return r.db.Create(history).Error
}
