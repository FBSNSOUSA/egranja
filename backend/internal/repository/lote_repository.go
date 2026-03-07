package repository

import (
	"errors"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrLoteNotFound = errors.New("lote nao encontrado")
)

// LoteRepository gerencia operacoes de persistencia de lotes.
type LoteRepository struct {
	db *gorm.DB
}

// NewLoteRepository cria uma nova instancia de LoteRepository.
func NewLoteRepository(db *gorm.DB) *LoteRepository {
	return &LoteRepository{db: db}
}

// DB retorna a instancia do gorm.DB para queries customizadas.
func (r *LoteRepository) DB() *gorm.DB {
	return r.db
}

// Create cria um novo lote.
func (r *LoteRepository) Create(lote *model.Lote) error {
	return r.db.Create(lote).Error
}

// FindByID busca um lote pelo ID.
func (r *LoteRepository) FindByID(id uuid.UUID) (*model.Lote, error) {
	var lote model.Lote
	result := r.db.Preload("Galpao").Where("id = ?", id).First(&lote)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, ErrLoteNotFound
		}
		return nil, result.Error
	}
	return &lote, nil
}

// Update atualiza um lote existente.
func (r *LoteRepository) Update(lote *model.Lote) error {
	return r.db.Save(lote).Error
}

// Delete remove um lote pelo ID.
func (r *LoteRepository) Delete(id uuid.UUID) error {
	result := r.db.Delete(&model.Lote{}, "id = ?", id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return ErrLoteNotFound
	}
	return nil
}

// FindByUsuario busca lotes de um usuario com paginacao e filtro de status.
func (r *LoteRepository) FindByUsuario(usuarioID uuid.UUID, status string, page, perPage int) ([]model.Lote, int64, error) {
	var lotes []model.Lote
	var total int64

	query := r.db.Model(&model.Lote{}).Where("usuario_id = ?", usuarioID)

	if status != "" {
		query = query.Where("status = ?", status)
	}

	// Contar total
	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	// Buscar com paginacao
	offset := (page - 1) * perPage
	result := query.
		Preload("Galpao").
		Order("created_at DESC").
		Offset(offset).
		Limit(perPage).
		Find(&lotes)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return lotes, total, nil
}

// FindAcessiveis busca lotes do usuario (proprios + de galpoes de granjas colaboradas).
func (r *LoteRepository) FindAcessiveis(usuarioID uuid.UUID, granjaIDsColaboradas []uuid.UUID, status string, page, perPage int) ([]model.Lote, int64, error) {
	var lotes []model.Lote
	var total int64

	query := r.db.Model(&model.Lote{})
	if len(granjaIDsColaboradas) > 0 {
		query = query.Where(
			"usuario_id = ? OR galpao_id IN (SELECT id FROM galpaos WHERE granja_id IN ?)",
			usuarioID, granjaIDsColaboradas,
		)
	} else {
		query = query.Where("usuario_id = ?", usuarioID)
	}

	if status != "" {
		query = query.Where("status = ?", status)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Preload("Galpao").
		Order("created_at DESC").
		Offset(offset).
		Limit(perPage).
		Find(&lotes)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return lotes, total, nil
}

// FindAtivos busca todos os lotes ativos de um usuario.
func (r *LoteRepository) FindAtivos(usuarioID uuid.UUID) ([]model.Lote, error) {
	var lotes []model.Lote
	result := r.db.
		Preload("Galpao").
		Where("usuario_id = ? AND status = 'ativo'", usuarioID).
		Order("data_alojamento DESC").
		Find(&lotes)
	if result.Error != nil {
		return nil, result.Error
	}
	return lotes, nil
}

// FindAtivosByUsuarios busca lotes ativos de multiplos usuarios (util para tecnicos).
func (r *LoteRepository) FindAtivosByUsuarios(usuarioIDs []uuid.UUID) ([]model.Lote, error) {
	var lotes []model.Lote
	result := r.db.
		Preload("Galpao").
		Where("usuario_id IN ? AND status = 'ativo'", usuarioIDs).
		Order("data_alojamento DESC").
		Find(&lotes)
	if result.Error != nil {
		return nil, result.Error
	}
	return lotes, nil
}

// GetMortalidadeTotal calcula a mortalidade total de um lote.
func (r *LoteRepository) GetMortalidadeTotal(loteID uuid.UUID) (int, error) {
	var total int64
	result := r.db.Model(&model.Mortalidade{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade), 0)").
		Scan(&total)
	if result.Error != nil {
		return 0, result.Error
	}
	return int(total), nil
}

// GetUltimoPesoMedio retorna o peso medio da ultima pesagem de um lote.
func (r *LoteRepository) GetUltimoPesoMedio(loteID uuid.UUID) (*float64, error) {
	var pesagem model.Pesagem
	result := r.db.
		Where("lote_id = ?", loteID).
		Order("data DESC").
		First(&pesagem)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}
	return &pesagem.PesoMedio, nil
}

// GetConsumoTotalRacao retorna o consumo total de racao em kg de um lote.
func (r *LoteRepository) GetConsumoTotalRacao(loteID uuid.UUID) (float64, error) {
	var total float64
	result := r.db.Model(&model.FeedConsumption{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade_kg), 0)").
		Scan(&total)
	if result.Error != nil {
		return 0, result.Error
	}
	return total, nil
}

// GetRecebidoTotalRacao retorna o total recebido de racao em kg de um lote.
func (r *LoteRepository) GetRecebidoTotalRacao(loteID uuid.UUID) (float64, error) {
	var total float64
	result := r.db.Model(&model.FeedReceipt{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade_kg), 0)").
		Scan(&total)
	if result.Error != nil {
		return 0, result.Error
	}
	return total, nil
}

// GetConsumoAguaDia retorna o consumo de agua do ultimo dia registrado para um lote.
func (r *LoteRepository) GetConsumoAguaDia(loteID uuid.UUID) (*float64, error) {
	var consumo model.WaterConsumption
	result := r.db.
		Where("lote_id = ?", loteID).
		Order("data DESC").
		First(&consumo)
	if result.Error != nil {
		if errors.Is(result.Error, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, result.Error
	}
	return &consumo.QuantidadeLitros, nil
}

// GetConsumoTotalAgua retorna o consumo total de agua em litros de um lote.
func (r *LoteRepository) GetConsumoTotalAgua(loteID uuid.UUID) (float64, error) {
	var total float64
	result := r.db.Model(&model.WaterConsumption{}).
		Where("lote_id = ?", loteID).
		Select("COALESCE(SUM(quantidade_litros), 0)").
		Scan(&total)
	if result.Error != nil {
		return 0, result.Error
	}
	return total, nil
}
