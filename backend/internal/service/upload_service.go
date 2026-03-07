package service

import (
	"fmt"
	"io"
	"mime/multipart"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
	"go.uber.org/zap"
)

const (
	MaxPhotoSize = 5 * 1024 * 1024  // 5MB
	MaxAudioSize = 2 * 1024 * 1024  // 2MB
)

var allowedPhotoTypes = map[string]bool{
	"image/jpeg": true,
	"image/png":  true,
	"image/jpg":  true,
}

var allowedAudioTypes = map[string]bool{
	"audio/mpeg":      true,
	"audio/mp3":       true,
	"audio/ogg":       true,
	"audio/opus":      true,
	"audio/x-m4a":     true,
	"audio/mp4":       true,
}

// UploadResult representa o resultado de um upload.
type UploadResult struct {
	URL          string `json:"url"`
	ThumbnailURL string `json:"thumbnail_url,omitempty"`
	FileName     string `json:"file_name"`
	ContentType  string `json:"content_type"`
	Size         int64  `json:"size"`
}

// UploadService gerencia uploads de arquivos.
type UploadService struct {
	logger *zap.Logger
}

// NewUploadService cria uma nova instancia de UploadService.
func NewUploadService(logger *zap.Logger) *UploadService {
	return &UploadService{
		logger: logger,
	}
}

// ValidateFile valida o tipo e tamanho do arquivo.
func (s *UploadService) ValidateFile(header *multipart.FileHeader) error {
	contentType := header.Header.Get("Content-Type")

	isPhoto := allowedPhotoTypes[contentType]
	isAudio := allowedAudioTypes[contentType]

	if !isPhoto && !isAudio {
		return fmt.Errorf("tipo de arquivo nao permitido: %s. Tipos aceitos: JPEG, PNG, MP3, OGG", contentType)
	}

	if isPhoto && header.Size > MaxPhotoSize {
		return fmt.Errorf("foto excede o tamanho maximo de 5MB (tamanho: %d bytes)", header.Size)
	}

	if isAudio && header.Size > MaxAudioSize {
		return fmt.Errorf("audio excede o tamanho maximo de 2MB (tamanho: %d bytes)", header.Size)
	}

	return nil
}

// ProcessUpload processa o upload de um arquivo.
// Em producao, faria o upload para MinIO/S3. Neste momento, gera a URL esperada.
func (s *UploadService) ProcessUpload(file multipart.File, header *multipart.FileHeader) (*UploadResult, error) {
	if err := s.ValidateFile(header); err != nil {
		return nil, err
	}

	// Gerar nome unico para o arquivo
	ext := filepath.Ext(header.Filename)
	fileName := fmt.Sprintf("%s_%d%s",
		uuid.New().String(),
		time.Now().UnixMilli(),
		ext,
	)

	contentType := header.Header.Get("Content-Type")

	// Determinar pasta (fotos ou audios)
	folder := "fotos"
	if allowedAudioTypes[contentType] {
		folder = "audios"
	}

	// Em producao, aqui faria o upload para MinIO
	// Por agora, geramos a URL que seria gerada
	url := fmt.Sprintf("/media/%s/%s", folder, fileName)

	// Consumir o reader para nao ter leak
	_, _ = io.Copy(io.Discard, file)

	result := &UploadResult{
		URL:         url,
		FileName:    fileName,
		ContentType: contentType,
		Size:        header.Size,
	}

	// Para fotos, gerar URL de thumbnail
	if allowedPhotoTypes[contentType] {
		thumbName := strings.TrimSuffix(fileName, ext) + "_thumb" + ext
		result.ThumbnailURL = fmt.Sprintf("/media/%s/thumbs/%s", folder, thumbName)
	}

	s.logger.Info("Arquivo processado para upload",
		zap.String("fileName", fileName),
		zap.String("contentType", contentType),
		zap.Int64("size", header.Size),
	)

	return result, nil
}
