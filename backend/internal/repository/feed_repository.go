package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// FeedRepository gerencia operacoes de persistencia de racao (recebimentos e consumos).
type FeedRepository struct {
	db *gorm.DB
}

// NewFeedRepository cria uma nova instancia de FeedRepository.
func NewFeedRepository(db *gorm.DB) *FeedRepository {
	return &FeedRepository{db: db}
}

// CreateReceipt cria um novo recebimento de racao.
func (r *FeedRepository) CreateReceipt(receipt *model.FeedReceipt) error {
	return r.db.Create(receipt).Error
}

// FindReceiptsByLote busca recebimentos de racao de um lote.
func (r *FeedRepository) FindReceiptsByLote(loteID uuid.UUID, page, perPage int) ([]model.FeedReceipt, int64, error) {
	var receipts []model.FeedReceipt
	var total int64

	query := r.db.Model(&model.FeedReceipt{}).Where("lote_id = ?", loteID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Preload("TipoRacao").
		Order("data_recebimento DESC").
		Offset(offset).
		Limit(perPage).
		Find(&receipts)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return receipts, total, nil
}

// CreateConsumption cria um novo consumo de racao.
func (r *FeedRepository) CreateConsumption(consumption *model.FeedConsumption) error {
	return r.db.Create(consumption).Error
}

// FindConsumptionsByLote busca consumos de racao de um lote.
func (r *FeedRepository) FindConsumptionsByLote(loteID uuid.UUID, page, perPage int) ([]model.FeedConsumption, int64, error) {
	var consumptions []model.FeedConsumption
	var total int64

	query := r.db.Model(&model.FeedConsumption{}).Where("lote_id = ?", loteID)

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Order("data DESC").
		Offset(offset).
		Limit(perPage).
		Find(&consumptions)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return consumptions, total, nil
}

// SaldoAtual calcula o saldo atual de racao de um lote.
func (r *FeedRepository) SaldoAtual(loteID uuid.UUID) (recebido float64, consumido float64, err error) {
	// Recebido total
	result := r.db.Model(&model.FeedReceipt{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade_kg), 0)").
		Scan(&recebido)
	if result.Error != nil {
		return 0, 0, result.Error
	}

	// Consumido total
	result = r.db.Model(&model.FeedConsumption{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade_kg), 0)").
		Scan(&consumido)
	if result.Error != nil {
		return 0, 0, result.Error
	}

	return recebido, consumido, nil
}

// ConsumoTotal retorna o consumo total de racao de um lote.
func (r *FeedRepository) ConsumoTotal(loteID uuid.UUID) (float64, error) {
	var total float64
	result := r.db.Model(&model.FeedConsumption{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade_kg), 0)").
		Scan(&total)
	return total, result.Error
}
