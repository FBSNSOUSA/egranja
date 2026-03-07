package repository

import (
	"github.com/FBSNSOUSA/egranja/backend/internal/model"
	"gorm.io/gorm"
)

// BenchmarkRepository gerencia operacoes de persistencia de benchmarks.
type BenchmarkRepository struct {
	db *gorm.DB
}

// NewBenchmarkRepository cria uma nova instancia de BenchmarkRepository.
func NewBenchmarkRepository(db *gorm.DB) *BenchmarkRepository {
	return &BenchmarkRepository{db: db}
}

// FindByLinhagem busca todos os benchmarks de uma linhagem.
func (r *BenchmarkRepository) FindByLinhagem(linhagem string) ([]model.BenchmarkLinhagem, error) {
	var benchmarks []model.BenchmarkLinhagem
	result := r.db.Where("linhagem = ?", linhagem).Order("dia ASC").Find(&benchmarks)
	if result.Error != nil {
		return nil, result.Error
	}
	return benchmarks, nil
}

// FindByLinhagemDia busca o benchmark de uma linhagem para um dia especifico.
func (r *BenchmarkRepository) FindByLinhagemDia(linhagem string, dia int) (*model.BenchmarkLinhagem, error) {
	var bench model.BenchmarkLinhagem
	result := r.db.Where("linhagem = ? AND dia = ?", linhagem, dia).First(&bench)
	if result.Error != nil {
		if result.Error == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, result.Error
	}
	return &bench, nil
}
