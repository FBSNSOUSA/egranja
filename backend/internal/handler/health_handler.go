package handler

import (
	"net/http"
	"time"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// HealthHandler gerencia o endpoint de health check.
type HealthHandler struct {
	db        *gorm.DB
	startTime time.Time
}

// NewHealthHandler cria uma nova instancia de HealthHandler.
func NewHealthHandler(db *gorm.DB) *HealthHandler {
	return &HealthHandler{
		db:        db,
		startTime: time.Now(),
	}
}

// HealthCheckResponse representa a resposta do health check.
type HealthCheckResponse struct {
	Status   string `json:"status"`
	Uptime   string `json:"uptime"`
	Database string `json:"database"`
	Version  string `json:"version"`
}

// Check godoc
// @Summary      Health check
// @Description  Verifica o status do servidor e da conexao com o banco de dados
// @Tags         health
// @Produce      json
// @Success      200 {object} dto.SuccessResponse{data=HealthCheckResponse}
// @Failure      503 {object} dto.ErrorResponse
// @Router       /health [get]
func (h *HealthHandler) Check(c *gin.Context) {
	dbStatus := "ok"

	// Verificar conexao com o banco
	sqlDB, err := h.db.DB()
	if err != nil {
		dbStatus = "error: " + err.Error()
	} else {
		if err := sqlDB.Ping(); err != nil {
			dbStatus = "error: " + err.Error()
		}
	}

	uptime := time.Since(h.startTime).Round(time.Second).String()

	status := "healthy"
	statusCode := http.StatusOK
	if dbStatus != "ok" {
		status = "degraded"
		statusCode = http.StatusServiceUnavailable
	}

	response := HealthCheckResponse{
		Status:   status,
		Uptime:   uptime,
		Database: dbStatus,
		Version:  "1.0.0",
	}

	if statusCode == http.StatusOK {
		dto.RespondSuccess(c, statusCode, response)
	} else {
		c.JSON(statusCode, gin.H{
			"success": false,
			"data":    response,
			"error": gin.H{
				"code":    "SERVICE_UNAVAILABLE",
				"message": "Servico degradado.",
			},
		})
	}
}
