package handler

import (
	"net/http"

	"github.com/FBSNSOUSA/egranja/backend/internal/dto"
	"github.com/FBSNSOUSA/egranja/backend/internal/middleware"
	"github.com/FBSNSOUSA/egranja/backend/internal/service"
	"github.com/gin-gonic/gin"
	"go.uber.org/zap"
)

// UploadHandler gerencia os endpoints de upload de midia.
type UploadHandler struct {
	uploadService *service.UploadService
	logger        *zap.Logger
}

// NewUploadHandler cria uma nova instancia de UploadHandler.
func NewUploadHandler(uploadService *service.UploadService, logger *zap.Logger) *UploadHandler {
	return &UploadHandler{
		uploadService: uploadService,
		logger:        logger,
	}
}

// Upload godoc
// @Summary      Upload de midia
// @Description  Faz upload de foto (JPEG/PNG, max 5MB) ou audio (MP3/OGG, max 2MB)
// @Tags         upload
// @Accept       multipart/form-data
// @Produce      json
// @Security     BearerAuth
// @Param        file formance file true "Arquivo para upload"
// @Success      200 {object} dto.SuccessResponse{data=service.UploadResult}
// @Failure      400 {object} dto.ErrorResponse
// @Failure      413 {object} dto.ErrorResponse
// @Router       /upload [post]
func (h *UploadHandler) Upload(c *gin.Context) {
	_, ok := middleware.GetUserIDFromContext(c)
	if !ok {
		dto.RespondUnauthorized(c, "Usuario nao autenticado.")
		return
	}

	file, header, err := c.Request.FormFile("file")
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "BAD_REQUEST", "Arquivo nao encontrado no request. Use o campo 'file'.")
		return
	}
	defer file.Close()

	// Validar e processar upload
	result, err := h.uploadService.ProcessUpload(file, header)
	if err != nil {
		dto.RespondError(c, http.StatusBadRequest, "INVALID_FILE", err.Error())
		return
	}

	dto.RespondSuccess(c, http.StatusOK, result)
}
