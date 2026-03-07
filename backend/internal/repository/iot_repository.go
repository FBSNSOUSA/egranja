package repository

import (
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

// IoTRepository gerencia operacoes de persistencia de leituras IoT.
type IoTRepository struct {
	db *gorm.DB
}

// NewIoTRepository cria uma nova instancia de IoTRepository.
func NewIoTRepository(db *gorm.DB) *IoTRepository {
	return &IoTRepository{db: db}
}

// Create cria uma nova leitura IoT.
func (r *IoTRepository) Create(reading *model.IotReading) error {
	return r.db.Create(reading).Error
}

// FindByGalpaoID busca leituras IoT de um galpao com filtro de periodo e paginacao.
func (r *IoTRepository) FindByGalpaoID(galpaoID uuid.UUID, from, to time.Time, page, perPage int) ([]model.IotReading, int64, error) {
	var readings []model.IotReading
	var total int64

	query := r.db.Model(&model.IotReading{}).Where("galpao_id = ?", galpaoID)

	if !from.IsZero() {
		query = query.Where("timestamp >= ?", from)
	}
	if !to.IsZero() {
		query = query.Where("timestamp <= ?", to)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, 0, err
	}

	offset := (page - 1) * perPage
	result := query.
		Order("timestamp DESC").
		Offset(offset).
		Limit(perPage).
		Find(&readings)

	if result.Error != nil {
		return nil, 0, result.Error
	}

	return readings, total, nil
}

// FindLatestByGalpao busca a ultima leitura de cada tipo de sensor para um galpao.
func (r *IoTRepository) FindLatestByGalpao(galpaoID uuid.UUID) ([]model.IotReading, error) {
	var readings []model.IotReading

	// Subquery para pegar o max timestamp de cada sensor_tipo
	result := r.db.Raw(`
		SELECT DISTINCT ON (sensor_tipo) *
		FROM iot_readings
		WHERE galpao_id = ?
		ORDER BY sensor_tipo, timestamp DESC
	`, galpaoID).Scan(&readings)

	if result.Error != nil {
		return nil, result.Error
	}

	return readings, nil
}

// IoTAgregado representa um registro agregado de IoT.
type IoTAgregado struct {
	Periodo    time.Time `json:"periodo"`
	SensorTipo string    `json:"sensor_tipo"`
	Media      float64   `json:"media"`
	Minimo     float64   `json:"minimo"`
	Maximo     float64   `json:"maximo"`
	Contagem   int       `json:"contagem"`
}

// FindAgregado busca dados agregados por hora ou dia para graficos.
func (r *IoTRepository) FindAgregado(galpaoID uuid.UUID, from, to time.Time, intervalo string) ([]IoTAgregado, error) {
	var agregados []IoTAgregado

	truncExpr := "date_trunc('hour', timestamp)"
	if intervalo == "dia" {
		truncExpr = "date_trunc('day', timestamp)"
	}

	query := r.db.Raw(`
		SELECT 
			`+truncExpr+` AS periodo,
			sensor_tipo,
			AVG(valor) AS media,
			MIN(valor) AS minimo,
			MAX(valor) AS maximo,
			COUNT(*) AS contagem
		FROM iot_readings
		WHERE galpao_id = ?
			AND timestamp >= ?
			AND timestamp <= ?
		GROUP BY periodo, sensor_tipo
		ORDER BY periodo ASC, sensor_tipo ASC
	`, galpaoID, from, to)

	if err := query.Scan(&agregados).Error; err != nil {
		return nil, err
	}

	return agregados, nil
}
