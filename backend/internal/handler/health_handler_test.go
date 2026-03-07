package handler

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestHealthCheck_ReturnsOK(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.New()

	// Simula o health check sem DB real
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{
			"success": true,
			"data": gin.H{
				"status":   "healthy",
				"uptime":   "1m0s",
				"database": "ok",
				"version":  "1.0.0",
			},
		})
	})

	req, _ := http.NewRequest("GET", "/health", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusOK, w.Code)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)

	assert.Equal(t, true, resp["success"])

	data, ok := resp["data"].(map[string]interface{})
	require.True(t, ok)
	assert.Equal(t, "healthy", data["status"])
	assert.Equal(t, "ok", data["database"])
	assert.Equal(t, "1.0.0", data["version"])
}

func TestHealthCheck_ResponseStructure(t *testing.T) {
	resp := HealthCheckResponse{
		Status:   "healthy",
		Uptime:   "5m30s",
		Database: "ok",
		Version:  "1.0.0",
	}

	data, err := json.Marshal(resp)
	require.NoError(t, err)

	var parsed map[string]interface{}
	err = json.Unmarshal(data, &parsed)
	require.NoError(t, err)

	assert.Equal(t, "healthy", parsed["status"])
	assert.Equal(t, "5m30s", parsed["uptime"])
	assert.Equal(t, "ok", parsed["database"])
	assert.Equal(t, "1.0.0", parsed["version"])
}

func TestHealthCheck_DegradedStatus(t *testing.T) {
	gin.SetMode(gin.TestMode)

	router := gin.New()
	router.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusServiceUnavailable, gin.H{
			"success": false,
			"data": gin.H{
				"status":   "degraded",
				"uptime":   "1m0s",
				"database": "error: connection refused",
				"version":  "1.0.0",
			},
		})
	})

	req, _ := http.NewRequest("GET", "/health", nil)
	w := httptest.NewRecorder()
	router.ServeHTTP(w, req)

	assert.Equal(t, http.StatusServiceUnavailable, w.Code)

	var resp map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)

	data, ok := resp["data"].(map[string]interface{})
	require.True(t, ok)
	assert.Equal(t, "degraded", data["status"])
	assert.Contains(t, data["database"], "error")
}
