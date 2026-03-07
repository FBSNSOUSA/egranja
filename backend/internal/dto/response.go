package dto

import (
	"math"
	"net/http"

	"github.com/gin-gonic/gin"
)

// SuccessResponse representa a resposta padrao de sucesso da API.
type SuccessResponse struct {
	Success bool           `json:"success"`
	Data    interface{}    `json:"data"`
	Meta    *PaginationMeta `json:"meta,omitempty"`
}

// ErrorDetail representa os detalhes de um erro de validacao.
type ErrorDetail struct {
	Field   string `json:"field"`
	Message string `json:"message"`
}

// ErrorBody representa o corpo do erro na resposta.
type ErrorBody struct {
	Code    string        `json:"code"`
	Message string        `json:"message"`
	Details []ErrorDetail `json:"details,omitempty"`
}

// ErrorResponse representa a resposta padrao de erro da API.
type ErrorResponse struct {
	Success bool      `json:"success"`
	Error   ErrorBody `json:"error"`
}

// PaginationMeta representa os metadados de paginacao.
type PaginationMeta struct {
	Page       int   `json:"page"`
	PerPage    int   `json:"per_page"`
	Total      int64 `json:"total"`
	TotalPages int   `json:"total_pages"`
}

// NewPaginationMeta cria uma nova instancia de PaginationMeta.
func NewPaginationMeta(page, perPage int, total int64) *PaginationMeta {
	totalPages := int(math.Ceil(float64(total) / float64(perPage)))
	if totalPages < 1 {
		totalPages = 1
	}
	return &PaginationMeta{
		Page:       page,
		PerPage:    perPage,
		Total:      total,
		TotalPages: totalPages,
	}
}

// RespondSuccess envia uma resposta de sucesso sem paginacao.
func RespondSuccess(c *gin.Context, statusCode int, data interface{}) {
	c.JSON(statusCode, SuccessResponse{
		Success: true,
		Data:    data,
	})
}

// RespondSuccessWithPagination envia uma resposta de sucesso com metadados de paginacao.
func RespondSuccessWithPagination(c *gin.Context, data interface{}, meta *PaginationMeta) {
	c.JSON(http.StatusOK, SuccessResponse{
		Success: true,
		Data:    data,
		Meta:    meta,
	})
}

// RespondError envia uma resposta de erro padronizada.
func RespondError(c *gin.Context, statusCode int, code, message string, details ...ErrorDetail) {
	resp := ErrorResponse{
		Success: false,
		Error: ErrorBody{
			Code:    code,
			Message: message,
		},
	}
	if len(details) > 0 {
		resp.Error.Details = details
	}
	c.JSON(statusCode, resp)
}

// RespondValidationError envia uma resposta de erro de validacao.
func RespondValidationError(c *gin.Context, details []ErrorDetail) {
	RespondError(c, http.StatusUnprocessableEntity, "VALIDATION_ERROR", "Erro de validacao nos dados enviados.", details...)
}

// RespondNotFound envia uma resposta 404.
func RespondNotFound(c *gin.Context, message string) {
	RespondError(c, http.StatusNotFound, "NOT_FOUND", message)
}

// RespondUnauthorized envia uma resposta 401.
func RespondUnauthorized(c *gin.Context, message string) {
	RespondError(c, http.StatusUnauthorized, "UNAUTHORIZED", message)
}

// RespondForbidden envia uma resposta 403.
func RespondForbidden(c *gin.Context, message string) {
	RespondError(c, http.StatusForbidden, "FORBIDDEN", message)
}

// RespondInternalError envia uma resposta 500.
func RespondInternalError(c *gin.Context, message string) {
	RespondError(c, http.StatusInternalServerError, "INTERNAL_ERROR", message)
}

// ParsePagination extrai page e per_page dos query params com valores padrao.
func ParsePagination(c *gin.Context) (page int, perPage int) {
	page = 1
	perPage = 20

	if p := c.Query("page"); p != "" {
		if val := parseInt(p); val > 0 {
			page = val
		}
	}
	if pp := c.Query("per_page"); pp != "" {
		if val := parseInt(pp); val > 0 && val <= 100 {
			perPage = val
		}
	}
	return
}

// Offset calcula o offset para paginacao.
func Offset(page, perPage int) int {
	return (page - 1) * perPage
}

func parseInt(s string) int {
	var n int
	for _, c := range s {
		if c >= '0' && c <= '9' {
			n = n*10 + int(c-'0')
		} else {
			return 0
		}
	}
	return n
}
