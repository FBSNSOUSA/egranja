import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/features/lote_detail/domain/entities/mortalidade.dart';

void main() {
  group('Mortalidade', () {
    test('fromJson cria instancia com todos os campos', () {
      final json = {
        'id': 'mort-1',
        'lote_id': 'lote-1',
        'data': '2025-06-15',
        'quantidade': 5,
        'causa': 'morte_subita',
        'observacao': 'Encontradas pela manha',
        'created_at': '2025-06-15T08:00:00Z',
      };

      final mortalidade = Mortalidade.fromJson(json);

      expect(mortalidade.id, 'mort-1');
      expect(mortalidade.loteId, 'lote-1');
      expect(mortalidade.data, '2025-06-15');
      expect(mortalidade.quantidade, 5);
      expect(mortalidade.causa, 'morte_subita');
      expect(mortalidade.observacao, 'Encontradas pela manha');
      expect(mortalidade.createdAt, '2025-06-15T08:00:00Z');
    });

    test('fromJson campos opcionais nulos', () {
      final json = {
        'id': 'mort-2',
        'lote_id': 'lote-1',
        'data': '2025-06-16',
        'quantidade': 2,
        'causa': 'ascite',
        'observacao': null,
        'created_at': '2025-06-16T08:00:00Z',
      };

      final mortalidade = Mortalidade.fromJson(json);

      expect(mortalidade.observacao, isNull);
    });

    test('fromJson causa nula usa default Indefinida', () {
      final json = {
        'id': 'mort-3',
        'lote_id': 'lote-1',
        'data': '2025-06-17',
        'quantidade': 1,
        'causa': null,
        'created_at': '2025-06-17T08:00:00Z',
      };

      final mortalidade = Mortalidade.fromJson(json);

      expect(mortalidade.causa, 'Indefinida');
    });

    test('toJson retorna mapa correto', () {
      const mortalidade = Mortalidade(
        id: 'mort-1',
        loteId: 'lote-1',
        data: '2025-06-15',
        quantidade: 5,
        causa: 'morte_subita',
        observacao: 'Observacao teste',
        createdAt: '2025-06-15T08:00:00Z',
      );

      final json = mortalidade.toJson();

      expect(json['id'], 'mort-1');
      expect(json['lote_id'], 'lote-1');
      expect(json['quantidade'], 5);
      expect(json['causa'], 'morte_subita');
      expect(json['observacao'], 'Observacao teste');
    });

    test('toJson omite observacao quando nula', () {
      const mortalidade = Mortalidade(
        id: 'mort-1',
        loteId: 'lote-1',
        data: '2025-06-15',
        quantidade: 5,
        causa: 'morte_subita',
        createdAt: '2025-06-15T08:00:00Z',
      );

      final json = mortalidade.toJson();

      expect(json.containsKey('observacao'), false);
    });

    test('fromJson/toJson round-trip preserva dados', () {
      final original = {
        'id': 'mort-3',
        'lote_id': 'lote-2',
        'data': '2025-07-01',
        'quantidade': 3,
        'causa': 'desconhecida',
        'created_at': '2025-07-01T12:00:00Z',
      };

      final mortalidade = Mortalidade.fromJson(original);
      final result = mortalidade.toJson();

      expect(result, original);
    });
  });
}
