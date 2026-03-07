package handler

import (
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/benchmark"
	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// BenchmarkHandler gerencia os endpoints de benchmarks.
type BenchmarkHandler struct {
	logger *zap.Logger
}

// NewBenchmarkHandler cria uma nova instancia de BenchmarkHandler.
func NewBenchmarkHandler(logger *zap.Logger) *BenchmarkHandler {
	return &BenchmarkHandler{
		logger: logger,
	}
}

// BenchmarkEntryResponse representa uma entrada de benchmark na resposta.
type BenchmarkEntryResponse struct {
	Dia          int     `json:"dia"`
	PesoG        float64 `json:"peso_g"`
	GPDG         float64 `json:"gpd_g"`
	ConsumoAcumG float64 `json:"consumo_acum_g"`
	CA           float64 `json:"ca"`
}

// Get godoc
// @Summary      Dados de benchmark da linhagem
// @Description  Retorna a tabela de referencia de uma linhagem
// @Tags         benchmarks
// @Produce      json
// @Security     BearerAuth
// @Param        linhagem path string true "Nome da linhagem (ex: Cobb 500, Ross 308)"
// @Success      200 {object} dto.SuccessResponse{data=[]BenchmarkEntryResponse}
// @Failure      404 {object} dto.ErrorResponse
// @Router       /benchmarks/{linhagem} [get]
func (h *BenchmarkHandler) Get(c *gin.Context) {
	linhagem := c.Param("linhagem")

	data := benchmark.GetBenchmarkData(linhagem)
	if data == nil {
		// Tentar com espaco (URL pode vir codificado)
		linhagens := benchmark.ListLinhagens()
		dto.RespondError(c, http.StatusNotFound, "NOT_FOUND",
			"Linhagem nao encontrada. Linhagens disponiveis: "+joinStrings(linhagens))
		return
	}

	var response []BenchmarkEntryResponse
	for _, entry := range data {
		response = append(response, BenchmarkEntryResponse{
			Dia:          entry.Dia,
			PesoG:        entry.PesoG,
			GPDG:         entry.GPDG,
			ConsumoAcumG: entry.ConsumoAcumG,
			CA:           entry.CA,
		})
	}

	dto.RespondSuccess(c, http.StatusOK, response)
}

func joinStrings(ss []string) string {
	result := ""
	for i, s := range ss {
		if i > 0 {
			result += ", "
		}
		result += s
	}
	return result
}
