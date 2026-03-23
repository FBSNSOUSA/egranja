import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/features/lote_detail/domain/entities/pesagem.dart';

void main() {
  group('PesagemItem', () {
    test('fromJson cria instancia corretamente', () {
      final json = {
        'id': 'item-1',
        'quantidade': 10,
        'peso': 25000.0,
        'peso_medio': 2500.0,
      };

      final item = PesagemItem.fromJson(json);

      expect(item.id, 'item-1');
      expect(item.quantidade, 10);
      expect(item.peso, 25000.0);
      expect(item.pesoMedio, 2500.0);
    });

    test('toJson retorna mapa correto', () {
      const item = PesagemItem(
        id: 'item-1',
        quantidade: 10,
        peso: 25000.0,
        pesoMedio: 2500.0,
      );

      final json = item.toJson();

      expect(json['id'], 'item-1');
      expect(json['quantidade'], 10);
      expect(json['peso'], 25000.0);
      expect(json['peso_medio'], 2500.0);
    });

    test('fromJson/toJson round-trip preserva dados', () {
      final original = {
        'id': 'item-2',
        'quantidade': 5,
        'peso': 12500.0,
        'peso_medio': 2500.0,
      };

      final item = PesagemItem.fromJson(original);
      final result = item.toJson();

      expect(result, original);
    });
  });

  group('Pesagem', () {
    test('fromJson cria instancia com todos os campos', () {
      final json = {
        'id': 'pes-1',
        'lote_id': 'lote-1',
        'data': '2025-06-15',
        'quantidade_total': 20,
        'peso_total': 50000.0,
        'peso_medio': 2500.0,
        'items': [
          {
            'id': 'item-1',
            'quantidade': 10,
            'peso': 25000.0,
            'peso_medio': 2500.0,
          },
        ],
        'created_at': '2025-06-15T10:00:00Z',
      };

      final pesagem = Pesagem.fromJson(json);

      expect(pesagem.id, 'pes-1');
      expect(pesagem.loteId, 'lote-1');
      expect(pesagem.data, '2025-06-15');
      expect(pesagem.quantidadeTotal, 20);
      expect(pesagem.pesoTotal, 50000.0);
      expect(pesagem.pesoMedio, 2500.0);
      expect(pesagem.items.length, 1);
      expect(pesagem.items[0].id, 'item-1');
      expect(pesagem.createdAt, '2025-06-15T10:00:00Z');
    });

    test('fromJson items nulo gera lista vazia', () {
      final json = {
        'id': 'pes-2',
        'lote_id': 'lote-1',
        'data': '2025-06-15',
        'quantidade_total': 10,
        'peso_total': 25000.0,
        'peso_medio': 2500.0,
        'items': null,
        'created_at': '2025-06-15T10:00:00Z',
      };

      final pesagem = Pesagem.fromJson(json);

      expect(pesagem.items, isEmpty);
    });

    test('toJson retorna mapa completo', () {
      const pesagem = Pesagem(
        id: 'pes-1',
        loteId: 'lote-1',
        data: '2025-06-15',
        quantidadeTotal: 20,
        pesoTotal: 50000.0,
        pesoMedio: 2500.0,
        items: [],
        createdAt: '2025-06-15T10:00:00Z',
      );

      final json = pesagem.toJson();

      expect(json['id'], 'pes-1');
      expect(json['lote_id'], 'lote-1');
      expect(json['quantidade_total'], 20);
      expect(json['peso_total'], 50000.0);
      expect(json['peso_medio'], 2500.0);
      expect(json['items'], isEmpty);
    });

    test('fromJson/toJson round-trip preserva dados', () {
      final original = {
        'id': 'pes-3',
        'lote_id': 'lote-2',
        'data': '2025-07-01',
        'quantidade_total': 15,
        'peso_total': 37500.0,
        'peso_medio': 2500.0,
        'items': <dynamic>[],
        'created_at': '2025-07-01T10:00:00Z',
      };

      final pesagem = Pesagem.fromJson(original);
      final result = pesagem.toJson();

      expect(result['id'], original['id']);
      expect(result['lote_id'], original['lote_id']);
      expect(result['quantidade_total'], original['quantidade_total']);
      expect(result['peso_total'], original['peso_total']);
      expect(result['peso_medio'], original['peso_medio']);
    });
  });
}
