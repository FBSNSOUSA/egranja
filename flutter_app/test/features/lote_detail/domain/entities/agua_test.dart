import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/features/lote_detail/domain/entities/agua.dart';

void main() {
  group('ConsumoAgua', () {
    test('fromJson cria instancia com todos os campos', () {
      final json = {
        'id': 'agua-1',
        'lote_id': 'lote-1',
        'data': '2025-06-15',
        'quantidade_litros': 1500.0,
        'consumo_por_ave': 150.0,
        'relacao_agua_racao': 1.8,
        'created_at': '2025-06-15T18:00:00Z',
      };

      final consumo = ConsumoAgua.fromJson(json);

      expect(consumo.id, 'agua-1');
      expect(consumo.loteId, 'lote-1');
      expect(consumo.data, '2025-06-15');
      expect(consumo.quantidadeLitros, 1500.0);
      expect(consumo.consumoPorAve, 150.0);
      expect(consumo.relacaoAguaRacao, 1.8);
      expect(consumo.createdAt, '2025-06-15T18:00:00Z');
    });

    test('fromJson campos opcionais nulos', () {
      final json = {
        'id': 'agua-2',
        'lote_id': 'lote-1',
        'data': '2025-06-16',
        'quantidade_litros': 1200.0,
        'consumo_por_ave': null,
        'relacao_agua_racao': null,
        'created_at': '2025-06-16T18:00:00Z',
      };

      final consumo = ConsumoAgua.fromJson(json);

      expect(consumo.consumoPorAve, isNull);
      expect(consumo.relacaoAguaRacao, isNull);
    });

    test('toJson retorna mapa correto', () {
      const consumo = ConsumoAgua(
        id: 'agua-1',
        loteId: 'lote-1',
        data: '2025-06-15',
        quantidadeLitros: 1500.0,
        consumoPorAve: 150.0,
        relacaoAguaRacao: 1.8,
        createdAt: '2025-06-15T18:00:00Z',
      );

      final json = consumo.toJson();

      expect(json['id'], 'agua-1');
      expect(json['lote_id'], 'lote-1');
      expect(json['quantidade_litros'], 1500.0);
      expect(json['consumo_por_ave'], 150.0);
      expect(json['relacao_agua_racao'], 1.8);
    });

    test('fromJson/toJson round-trip preserva dados', () {
      final original = {
        'id': 'agua-3',
        'lote_id': 'lote-2',
        'data': '2025-07-01',
        'quantidade_litros': 2000.0,
        'consumo_por_ave': null,
        'relacao_agua_racao': null,
        'created_at': '2025-07-01T18:00:00Z',
      };

      final consumo = ConsumoAgua.fromJson(original);
      final result = consumo.toJson();

      expect(result, original);
    });
  });
}
