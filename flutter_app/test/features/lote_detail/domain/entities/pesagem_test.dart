import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/features/lote_detail/domain/entities/pesagem.dart';

void main() {
  group('PesagemItem', () {
    test('fromJson cria instancia corretamente', () {
      final json = {
        'id': 'item-1',
        'pesagem_id': 'pes-1',
        'quantidade': 10,
        'peso': 25000.0,
        'peso_medio': 2500.0,
      };

      final item = PesagemItem.fromJson(json);

      expect(item.id, 'item-1');
      expect(item.pesagemId, 'pes-1');
      expect(item.quantidade, 10);
      expect(item.peso, 25000.0);
      expect(item.pesoMedio, 2500.0);
    });

    test('toJson retorna mapa correto', () {
      const item = PesagemItem(
        id: 'item-1',
        pesagemId: 'pes-1',
        quantidade: 10,
        peso: 25000.0,
        pesoMedio: 2500.0,
      );

      final json = item.toJson();

      expect(json['id'], 'item-1');
      expect(json['pesagem_id'], 'pes-1');
      expect(json['quantidade'], 10);
      expect(json['peso'], 25000.0);
      expect(json['peso_medio'], 2500.0);
    });

    test('fromJson/toJson round-trip preserva dados', () {
      final original = {
        'id': 'item-2',
        'pesagem_id': 'pes-2',
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
        'peso_benchmark': 2600.0,
        'desvio_pct': -3.85,
        'uniformidade_cv': 8.5,
        'idade': 28,
        'itens': [
          {
            'id': 'item-1',
            'pesagem_id': 'pes-1',
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
      expect(pesagem.pesoBenchmark, 2600.0);
      expect(pesagem.desvioPct, -3.85);
      expect(pesagem.uniformidadeCV, 8.5);
      expect(pesagem.idade, 28);
      expect(pesagem.itens.length, 1);
      expect(pesagem.itens[0].id, 'item-1');
      expect(pesagem.createdAt, '2025-06-15T10:00:00Z');
    });

    test('fromJson campos opcionais nulos', () {
      final json = {
        'id': 'pes-2',
        'lote_id': 'lote-1',
        'data': '2025-06-15',
        'quantidade_total': 10,
        'peso_total': 25000.0,
        'peso_medio': 2500.0,
        'peso_benchmark': null,
        'desvio_pct': null,
        'uniformidade_cv': null,
        'idade': null,
        'itens': null,
        'created_at': '2025-06-15T10:00:00Z',
      };

      final pesagem = Pesagem.fromJson(json);

      expect(pesagem.pesoBenchmark, isNull);
      expect(pesagem.desvioPct, isNull);
      expect(pesagem.uniformidadeCV, isNull);
      expect(pesagem.idade, isNull);
      expect(pesagem.itens, isEmpty);
    });

    test('toJson retorna mapa completo', () {
      const pesagem = Pesagem(
        id: 'pes-1',
        loteId: 'lote-1',
        data: '2025-06-15',
        quantidadeTotal: 20,
        pesoTotal: 50000.0,
        pesoMedio: 2500.0,
        pesoBenchmark: 2600.0,
        desvioPct: -3.85,
        uniformidadeCV: 8.5,
        idade: 28,
        itens: [],
        createdAt: '2025-06-15T10:00:00Z',
      );

      final json = pesagem.toJson();

      expect(json['id'], 'pes-1');
      expect(json['lote_id'], 'lote-1');
      expect(json['quantidade_total'], 20);
      expect(json['peso_benchmark'], 2600.0);
      expect(json['itens'], isEmpty);
    });
  });
}
