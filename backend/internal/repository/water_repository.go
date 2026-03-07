package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// WaterRepository gerencia operacoes de persistencia de consumo de agua.
type WaterRepository struct {
	db *gorm.DB
}

// NewWaterRepository cria uma nova instancia de WaterRepository.
func NewWaterRepository(db *gorm.DB) *WaterRepository {
	return &WaterRepository{db: db}
}

// Create cria um novo registro de consumo de agua.
func (r *WaterRepository) Create(consumption *model.WaterConsumption) error {
	return r.db.Create(consumption).Error
}

// FindByLote busca consumos de agua de um lote com paginacao.
func (r *WaterRepository) FindByLote(loteID uuid.UUID, page, perPage int) ([]model.WaterConsumption, int64, error) {
	var consumptions []model.WaterConsumption
	var total int64

	query := r.db.Model(&model.WaterConsumption{}).Where("lote_id = ?", loteID)

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

// ConsumoTotal retorna o consumo total de agua de um lote.
func (r *WaterRepository) ConsumoTotal(loteID uuid.UUID) (float64, error) {
	var total float64
	result := r.db.Model(&model.WaterConsumption{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade_litros), 0)").
		Scan(&total)
	return total, result.Error
}

// ConsumoDia retorna o consumo de agua de um dia especifico.
func (r *WaterRepository) ConsumoDia(loteID uuid.UUID) (*float64, error) {
	var consumo model.WaterConsumption
	result := r.db.
		Where("lote_id = ?", loteID).
		Order("data DESC").
		First(&consumo)
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, result.Error
	}
	return &consumo.QuantidadeLitros, nil
}

// RelacaoAguaRacao calcula a relacao agua/racao de um lote.
func (r *WaterRepository) RelacaoAguaRacao(loteID uuid.UUID) (*float64, error) {
	consumoAgua, err := r.ConsumoTotal(loteID)
	if err != nil {
		return nil, err
	}

	var consumoRacao float64
	result := r.db.Model(&model.FeedConsumption{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade_kg), 0)").
		Scan(&consumoRacao)
	if result.Error != nil {
		return nil, result.Error
	}

	if consumoRacao == 0 || consumoAgua == 0 {
		return nil, nil
	}

	relacao := consumoAgua / consumoRacao
	return &relacao, nil
}
