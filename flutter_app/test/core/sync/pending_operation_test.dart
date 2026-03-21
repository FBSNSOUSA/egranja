import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/sync/pending_operation.dart';

void main() {
  group('PendingOperation', () {
    test('fromJson cria instancia corretamente', () {
      final json = {
        'id': 'op-123',
        'method': 'POST',
        'url': '/lotes/abc/pesagens',
        'data': {'quantidade': 10, 'peso': 25000.0},
        'createdAt': '2025-06-15T10:00:00.000Z',
      };

      final op = PendingOperation.fromJson(json);

      expect(op.id, 'op-123');
      expect(op.method, 'POST');
      expect(op.url, '/lotes/abc/pesagens');
      expect(op.data, {'quantidade': 10, 'peso': 25000.0});
      expect(op.createdAt, DateTime.parse('2025-06-15T10:00:00.000Z'));
    });

    test('toJson retorna mapa correto', () {
      final op = PendingOperation(
        id: 'op-456',
        method: 'PATCH',
        url: '/lotes/abc',
        data: {'status': 'finalizado'},
        createdAt: DateTime.parse('2025-07-01T12:00:00.000Z'),
      );

      final json = op.toJson();

      expect(json['id'], 'op-456');
      expect(json['method'], 'PATCH');
      expect(json['url'], '/lotes/abc');
      expect(json['data'], {'status': 'finalizado'});
      expect(json['createdAt'], '2025-07-01T12:00:00.000Z');
    });

    test('fromJson/toJson round-trip preserva dados', () {
      final original = {
        'id': 'op-789',
        'method': 'DELETE',
        'url': '/mortalidades/123',
        'data': null,
        'createdAt': '2025-08-01T00:00:00.000Z',
      };

      final op = PendingOperation.fromJson(original);
      final result = op.toJson();

      expect(result['id'], original['id']);
      expect(result['method'], original['method']);
      expect(result['url'], original['url']);
      expect(result['data'], original['data']);
      expect(result['createdAt'], original['createdAt']);
    });

    test('fromJson com data nulo cria instancia sem dados', () {
      final json = {
        'id': 'op-no-data',
        'method': 'DELETE',
        'url': '/lotes/xyz',
        'data': null,
        'createdAt': '2025-06-15T10:00:00.000Z',
      };

      final op = PendingOperation.fromJson(json);

      expect(op.data, isNull);
    });

    test('toString retorna representacao legivel', () {
      final op = PendingOperation(
        id: 'op-str',
        method: 'POST',
        url: '/test',
        createdAt: DateTime.parse('2025-01-01T00:00:00.000Z'),
      );

      final str = op.toString();

      expect(str, contains('op-str'));
      expect(str, contains('POST'));
      expect(str, contains('/test'));
    });
  });
}
