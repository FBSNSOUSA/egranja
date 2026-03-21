import 'package:flutter_test/flutter_test.dart';
import 'package:egranja_flutter/features/home/data/models/lote_model.dart';

void main() {
  group('LoteModel', () {
    final sampleJson = {
      'id': 'lote-001',
      'galpao_id': 'galpao-1',
      'galpao_nome': 'Galpao Norte',
      'data_alojamento': '2025-03-01',
      'data_prevista_abate': '2025-04-15',
      'quantidade': 25000,
      'tipo': 'Misto',
      'linhagem': 'Cobb 500',
      'peso_inicial_g': 42.5,
      'status': 'ativo',
      'mortalidade_acumulada': 120,
      'ultimo_peso_medio': 1850.0,
      'peso_benchmark': 1900.0,
      'mortes_recentes': 5,
      'data_mortes_recentes': '2025-03-20',
      'mortalidade_recente_pct': 0.02,
      'tem_alerta': true,
      'quantidade_alertas': 2,
      'dias_de_vida': 21,
      'aves_vivas': 24880,
      'created_at': '2025-03-01T00:00:00Z',
      'updated_at': '2025-03-21T10:00:00Z',
    };

    group('fromJson', () {
      test('cria instancia com todos os campos', () {
        final model = LoteModel.fromJson(sampleJson);

        expect(model.id, 'lote-001');
        expect(model.galpaoId, 'galpao-1');
        expect(model.galpaoNome, 'Galpao Norte');
        expect(model.dataAlojamento, '2025-03-01');
        expect(model.dataPrevistaAbate, '2025-04-15');
        expect(model.quantidade, 25000);
        expect(model.tipo, 'Misto');
        expect(model.linhagem, 'Cobb 500');
        expect(model.pesoInicialG, 42.5);
        expect(model.status, 'ativo');
        expect(model.mortalidadeAcumulada, 120);
        expect(model.ultimoPesoMedio, 1850.0);
        expect(model.pesoBenchmark, 1900.0);
        expect(model.mortesRecentes, 5);
        expect(model.temAlerta, true);
        expect(model.quantidadeAlertas, 2);
        expect(model.diasDeVida, 21);
        expect(model.avesVivas, 24880);
      });

      test('cria instancia com campos opcionais nulos', () {
        final minimalJson = {
          'id': 'lote-002',
          'galpao_id': 'galpao-2',
          'data_alojamento': '2025-03-10',
          'data_prevista_abate': '2025-04-25',
          'quantidade': 20000,
          'tipo': 'Femea',
          'peso_inicial_g': 40,
          'status': 'ativo',
          'created_at': '2025-03-10T00:00:00Z',
          'updated_at': '2025-03-10T00:00:00Z',
        };

        final model = LoteModel.fromJson(minimalJson);

        expect(model.id, 'lote-002');
        expect(model.galpaoNome, ''); // default quando ausente
        expect(model.linhagem, isNull);
        expect(model.mortalidadeAcumulada, isNull);
        expect(model.ultimoPesoMedio, isNull);
        expect(model.temAlerta, isNull);
      });
    });

    group('toJson', () {
      test('serializa todos os campos corretamente', () {
        final model = LoteModel.fromJson(sampleJson);
        final json = model.toJson();

        expect(json['id'], 'lote-001');
        expect(json['galpao_id'], 'galpao-1');
        expect(json['galpao_nome'], 'Galpao Norte');
        expect(json['quantidade'], 25000);
        expect(json['peso_inicial_g'], 42.5);
        expect(json['status'], 'ativo');
        expect(json['dias_de_vida'], 21);
        expect(json['aves_vivas'], 24880);
      });
    });

    group('fromJson/toJson round-trip', () {
      test('preserva dados apos round-trip', () {
        final original = LoteModel.fromJson(sampleJson);
        final reconstructed = LoteModel.fromJson(original.toJson());

        expect(reconstructed.id, original.id);
        expect(reconstructed.galpaoId, original.galpaoId);
        expect(reconstructed.galpaoNome, original.galpaoNome);
        expect(reconstructed.quantidade, original.quantidade);
        expect(reconstructed.pesoInicialG, original.pesoInicialG);
        expect(reconstructed.status, original.status);
        expect(reconstructed.linhagem, original.linhagem);
        expect(reconstructed.mortalidadeAcumulada, original.mortalidadeAcumulada);
        expect(reconstructed.diasDeVida, original.diasDeVida);
      });
    });
  });
}
