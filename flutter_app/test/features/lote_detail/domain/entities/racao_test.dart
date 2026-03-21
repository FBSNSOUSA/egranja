import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/features/lote_detail/domain/entities/racao.dart';

void main() {
  group('RecebimentoRacao', () {
    test('fromJson cria instancia com todos os campos', () {
      final json = {
        'id': 'rec-1',
        'lote_id': 'lote-1',
        'data_recebimento': '2025-06-10',
        'quantidade_kg': 5000.0,
        'tipo_racao_id': 'tipo-1',
        'tipo_racao_nome': 'Inicial',
        'fornecedor': 'Cargill',
        'lote_racao': 'LR-2025-001',
        'origem': 'compra',
        'created_at': '2025-06-10T09:00:00Z',
      };

      final recebimento = RecebimentoRacao.fromJson(json);

      expect(recebimento.id, 'rec-1');
      expect(recebimento.loteId, 'lote-1');
      expect(recebimento.dataRecebimento, '2025-06-10');
      expect(recebimento.quantidadeKg, 5000.0);
      expect(recebimento.tipoRacaoId, 'tipo-1');
      expect(recebimento.tipoRacaoNome, 'Inicial');
      expect(recebimento.fornecedor, 'Cargill');
      expect(recebimento.loteRacao, 'LR-2025-001');
      expect(recebimento.origem, 'compra');
      expect(recebimento.createdAt, '2025-06-10T09:00:00Z');
    });

    test('fromJson campos opcionais nulos', () {
      final json = {
        'id': 'rec-2',
        'lote_id': 'lote-1',
        'data_recebimento': '2025-06-12',
        'quantidade_kg': 3000.0,
        'tipo_racao_id': null,
        'tipo_racao_nome': null,
        'fornecedor': null,
        'lote_racao': null,
        'origem': 'remanescente_anterior',
        'created_at': '2025-06-12T10:00:00Z',
      };

      final recebimento = RecebimentoRacao.fromJson(json);

      expect(recebimento.tipoRacaoId, isNull);
      expect(recebimento.tipoRacaoNome, isNull);
      expect(recebimento.fornecedor, isNull);
      expect(recebimento.loteRacao, isNull);
    });

    test('toJson retorna mapa correto', () {
      const recebimento = RecebimentoRacao(
        id: 'rec-1',
        loteId: 'lote-1',
        dataRecebimento: '2025-06-10',
        quantidadeKg: 5000.0,
        tipoRacaoId: 'tipo-1',
        tipoRacaoNome: 'Inicial',
        fornecedor: 'Cargill',
        loteRacao: 'LR-2025-001',
        origem: 'compra',
        createdAt: '2025-06-10T09:00:00Z',
      );

      final json = recebimento.toJson();

      expect(json['id'], 'rec-1');
      expect(json['data_recebimento'], '2025-06-10');
      expect(json['quantidade_kg'], 5000.0);
      expect(json['tipo_racao_nome'], 'Inicial');
      expect(json['origem'], 'compra');
    });
  });

  group('ConsumoRacao', () {
    test('fromJson cria instancia corretamente', () {
      final json = {
        'id': 'cons-1',
        'lote_id': 'lote-1',
        'data': '2025-06-15',
        'quantidade_kg': 250.5,
        'created_at': '2025-06-15T18:00:00Z',
      };

      final consumo = ConsumoRacao.fromJson(json);

      expect(consumo.id, 'cons-1');
      expect(consumo.loteId, 'lote-1');
      expect(consumo.data, '2025-06-15');
      expect(consumo.quantidadeKg, 250.5);
      expect(consumo.createdAt, '2025-06-15T18:00:00Z');
    });

    test('toJson retorna mapa correto', () {
      const consumo = ConsumoRacao(
        id: 'cons-1',
        loteId: 'lote-1',
        data: '2025-06-15',
        quantidadeKg: 250.5,
        createdAt: '2025-06-15T18:00:00Z',
      );

      final json = consumo.toJson();

      expect(json['id'], 'cons-1');
      expect(json['lote_id'], 'lote-1');
      expect(json['data'], '2025-06-15');
      expect(json['quantidade_kg'], 250.5);
    });

    test('fromJson/toJson round-trip preserva dados', () {
      final original = {
        'id': 'cons-2',
        'lote_id': 'lote-2',
        'data': '2025-07-01',
        'quantidade_kg': 300.0,
        'created_at': '2025-07-01T18:00:00Z',
      };

      final consumo = ConsumoRacao.fromJson(original);
      final result = consumo.toJson();

      expect(result, original);
    });
  });
}
