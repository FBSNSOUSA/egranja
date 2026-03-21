// Tipos de resposta padronizados da API eGranja.
//
// Espelham o formato do backend Go:
// - Sucesso: `{ "success": true, "data": T, "meta"?: PaginationMeta }`
// - Erro: `{ "success": false, "error": ApiError }`

/// Metadados de paginacao.
class PaginationMeta {
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const PaginationMeta({
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      total: json['total'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': perPage,
      'total': total,
      'total_pages': totalPages,
    };
  }
}

/// Resposta de sucesso padrao da API.
class SuccessResponse<T> {
  final bool success;
  final T data;
  final PaginationMeta? meta;

  const SuccessResponse({
    this.success = true,
    required this.data,
    this.meta,
  });

  factory SuccessResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return SuccessResponse<T>(
      success: json['success'] as bool? ?? true,
      data: fromJsonT(json['data']),
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Detalhe de erro de validacao por campo.
class FieldError {
  final String field;
  final String message;

  const FieldError({
    required this.field,
    required this.message,
  });

  factory FieldError.fromJson(Map<String, dynamic> json) {
    return FieldError(
      field: json['field'] as String,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field': field,
      'message': message,
    };
  }
}

/// Corpo de erro da API.
class ApiError {
  final String code;
  final String message;
  final List<FieldError>? details;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'] != null
          ? (json['details'] as List<dynamic>)
              .map((e) => FieldError.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      if (details != null) 'details': details!.map((e) => e.toJson()).toList(),
    };
  }
}

/// Resposta de erro padrao da API.
class ErrorResponse {
  final bool success;
  final ApiError error;

  const ErrorResponse({
    this.success = false,
    required this.error,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      success: json['success'] as bool? ?? false,
      error: ApiError.fromJson(json['error'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error': error.toJson(),
    };
  }
}
