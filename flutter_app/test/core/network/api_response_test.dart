import 'package:flutter_test/flutter_test.dart';
import 'package:egranja_flutter/core/network/api_response.dart';

void main() {
  group('PaginationMeta', () {
    test('fromJson cria instancia corretamente', () {
      final json = {
        'page': 1,
        'per_page': 20,
        'total': 50,
        'total_pages': 3,
      };

      final meta = PaginationMeta.fromJson(json);

      expect(meta.page, 1);
      expect(meta.perPage, 20);
      expect(meta.total, 50);
      expect(meta.totalPages, 3);
    });

    test('toJson serializa corretamente', () {
      const meta = PaginationMeta(
        page: 2,
        perPage: 10,
        total: 30,
        totalPages: 3,
      );

      final json = meta.toJson();

      expect(json['page'], 2);
      expect(json['per_page'], 10);
      expect(json['total'], 30);
      expect(json['total_pages'], 3);
    });

    test('fromJson/toJson round-trip preserva dados', () {
      const original = PaginationMeta(
        page: 1,
        perPage: 15,
        total: 100,
        totalPages: 7,
      );

      final reconstructed = PaginationMeta.fromJson(original.toJson());

      expect(reconstructed.page, original.page);
      expect(reconstructed.perPage, original.perPage);
      expect(reconstructed.total, original.total);
      expect(reconstructed.totalPages, original.totalPages);
    });
  });

  group('SuccessResponse', () {
    test('fromJson cria instancia sem meta', () {
      final json = {
        'success': true,
        'data': {'nome': 'Teste'},
      };

      final response = SuccessResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.success, true);
      expect(response.data['nome'], 'Teste');
      expect(response.meta, isNull);
    });

    test('fromJson cria instancia com meta de paginacao', () {
      final json = {
        'success': true,
        'data': [
          {'id': '1'},
          {'id': '2'},
        ],
        'meta': {
          'page': 1,
          'per_page': 10,
          'total': 2,
          'total_pages': 1,
        },
      };

      final response = SuccessResponse<List<dynamic>>.fromJson(
        json,
        (data) => data as List<dynamic>,
      );

      expect(response.success, true);
      expect(response.data.length, 2);
      expect(response.meta, isNotNull);
      expect(response.meta!.page, 1);
      expect(response.meta!.total, 2);
    });
  });

  group('FieldError', () {
    test('fromJson cria instancia corretamente', () {
      final json = {
        'field': 'email',
        'message': 'E-mail invalido',
      };

      final error = FieldError.fromJson(json);

      expect(error.field, 'email');
      expect(error.message, 'E-mail invalido');
    });

    test('toJson serializa corretamente', () {
      const error = FieldError(
        field: 'senha',
        message: 'Minimo 6 caracteres',
      );

      final json = error.toJson();

      expect(json['field'], 'senha');
      expect(json['message'], 'Minimo 6 caracteres');
    });

    test('fromJson/toJson round-trip preserva dados', () {
      const original = FieldError(
        field: 'login',
        message: 'Campo obrigatorio',
      );

      final reconstructed = FieldError.fromJson(original.toJson());

      expect(reconstructed.field, original.field);
      expect(reconstructed.message, original.message);
    });
  });

  group('ApiError', () {
    test('fromJson cria instancia sem details', () {
      final json = {
        'code': 'NOT_FOUND',
        'message': 'Recurso nao encontrado',
      };

      final error = ApiError.fromJson(json);

      expect(error.code, 'NOT_FOUND');
      expect(error.message, 'Recurso nao encontrado');
      expect(error.details, isNull);
    });

    test('fromJson cria instancia com details', () {
      final json = {
        'code': 'VALIDATION_ERROR',
        'message': 'Erro de validacao',
        'details': [
          {'field': 'email', 'message': 'E-mail invalido'},
          {'field': 'senha', 'message': 'Muito curta'},
        ],
      };

      final error = ApiError.fromJson(json);

      expect(error.code, 'VALIDATION_ERROR');
      expect(error.details, isNotNull);
      expect(error.details!.length, 2);
      expect(error.details![0].field, 'email');
      expect(error.details![1].message, 'Muito curta');
    });

    test('toJson serializa com details', () {
      const error = ApiError(
        code: 'VALIDATION_ERROR',
        message: 'Erro',
        details: [
          FieldError(field: 'nome', message: 'Obrigatorio'),
        ],
      );

      final json = error.toJson();

      expect(json['code'], 'VALIDATION_ERROR');
      expect(json['details'], isNotNull);
      expect((json['details'] as List).length, 1);
    });

    test('toJson omite details quando null', () {
      const error = ApiError(
        code: 'SERVER_ERROR',
        message: 'Erro interno',
      );

      final json = error.toJson();

      expect(json.containsKey('details'), false);
    });
  });

  group('ErrorResponse', () {
    test('fromJson cria instancia com erro', () {
      final json = {
        'success': false,
        'error': {
          'code': 'AUTH_ERROR',
          'message': 'Nao autorizado',
        },
      };

      final response = ErrorResponse.fromJson(json);

      expect(response.success, false);
      expect(response.error.code, 'AUTH_ERROR');
      expect(response.error.message, 'Nao autorizado');
    });

    test('fromJson com details no erro', () {
      final json = {
        'success': false,
        'error': {
          'code': 'VALIDATION_ERROR',
          'message': 'Dados invalidos',
          'details': [
            {'field': 'login', 'message': 'Obrigatorio'},
          ],
        },
      };

      final response = ErrorResponse.fromJson(json);

      expect(response.error.details, isNotNull);
      expect(response.error.details!.length, 1);
    });
  });
}
