import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/features/lote_detail/domain/entities/indicadores.dart';

void main() {
  group('Indicadores', () {
    Map<String, dynamic> buildFullJson() {
      return {
        'lote_id': 'lote-1',
        'dias_de_vida': 28,
        'aves_vivas': 9800,
        'aves_alojadas': 10000,
        'mortalidade_total': 200,
        'mortalidade_pct': 2.0,
        'ultimo_peso_medio': 1400.0,
        'peso_padrao_g': 1450.0,
        'desvio_peso_pct': -3.45,
        'gpd': 50.0,
        'ica': 1.65,
        'iea': 60.6,
        'iep': 320.0,
        'classificacao_iep': 'Bom',
        'viabilidade': 98.0,
        'recebido_total_racao_kg': 15000.0,
        'consumo_total_racao_kg': 12000.0,
        'saldo_racao_kg': 3000.0,
        'dias_estoque_racao': 7.0,
        'consumo_racao_por_ave': 428.6,
        'consumo_agua_dia_l': 1500.0,
        'relacao_agua_racao': 1.8,
        'projecao_peso': {
          'peso_estimado_g': 2800.0,
          'data_estimada': '2025-07-15',
          'gpd_g': 52.0,
          'mensagem': 'Lote com desempenho bom',
        },
      };
    }

    test('fromJson cria instancia com todos os campos', () {
      final json = buildFullJson();

      final indicadores = Indicadores.fromJson(json);

      expect(indicadores.loteId, 'lote-1');
      expect(indicadores.diasDeVida, 28);
      expect(indicadores.avesVivas, 9800);
      expect(indicadores.avesAlojadas, 10000);
      expect(indicadores.mortalidadeTotal, 200);
      expect(indicadores.mortalidadePct, 2.0);
      expect(indicadores.ultimoPesoMedio, 1400.0);
      expect(indicadores.pesoPadraoG, 1450.0);
      expect(indicadores.desvioPesoPct, -3.45);
      expect(indicadores.gpd, 50.0);
      expect(indicadores.ica, 1.65);
      expect(indicadores.iea, 60.6);
      expect(indicadores.iep, 320.0);
      expect(indicadores.classificacaoIep, 'Bom');
      expect(indicadores.viabilidade, 98.0);
      expect(indicadores.recebidoTotalRacaoKg, 15000.0);
      expect(indicadores.consumoTotalRacaoKg, 12000.0);
      expect(indicadores.saldoRacaoKg, 3000.0);
      expect(indicadores.diasEstoqueRacao, 7.0);
      expect(indicadores.consumoRacaoPorAve, 428.6);
      expect(indicadores.consumoAguaDiaL, 1500.0);
      expect(indicadores.relacaoAguaRacao, 1.8);
      expect(indicadores.projecaoPeso, isNotNull);
      expect(indicadores.projecaoPeso!.pesoEstimadoG, 2800.0);
      expect(indicadores.projecaoPeso!.mensagem, 'Lote com desempenho bom');
    });

    test('toJson retorna mapa correto', () {
      final json = buildFullJson();
      final indicadores = Indicadores.fromJson(json);
      final result = indicadores.toJson();

      expect(result['dias_de_vida'], 28);
      expect(result['aves_alojadas'], 10000);
      expect(result['mortalidade_total'], 200);
      expect(result['mortalidade_pct'], 2.0);
      expect(result['viabilidade'], 98.0);
      expect(result['ultimo_peso_medio'], 1400.0);
      expect(result['peso_padrao_g'], 1450.0);
      expect(result['classificacao_iep'], 'Bom');
      expect(result['saldo_racao_kg'], 3000.0);
      expect(result['consumo_agua_dia_l'], 1500.0);
      expect(result['relacao_agua_racao'], 1.8);
    });

    test('fromJson/toJson round-trip preserva dados', () {
      final original = buildFullJson();

      final indicadores = Indicadores.fromJson(original);
      final result = indicadores.toJson();

      // Required fields should match
      expect(result['dias_de_vida'], original['dias_de_vida']);
      expect(result['aves_vivas'], original['aves_vivas']);
      expect(result['aves_alojadas'], original['aves_alojadas']);
      expect(result['mortalidade_total'], original['mortalidade_total']);
      expect(result['viabilidade'], original['viabilidade']);
    });

    test('fromJson aceita valores inteiros para campos double', () {
      final json = buildFullJson();
      // Sobrescrever com int para validar que num.toDouble() funciona
      json['ultimo_peso_medio'] = 1400;
      json['peso_padrao_g'] = 1450;
      json['gpd'] = 50;

      final indicadores = Indicadores.fromJson(json);

      expect(indicadores.ultimoPesoMedio, 1400.0);
      expect(indicadores.pesoPadraoG, 1450.0);
      expect(indicadores.gpd, 50.0);
    });

    test('fromJson campos opcionais nulos usam defaults', () {
      final json = <String, dynamic>{
        'dias_de_vida': 10,
        'aves_vivas': 5000,
        'aves_alojadas': 5000,
        'mortalidade_total': 0,
        'mortalidade_pct': 0.0,
        'viabilidade': 100.0,
      };

      final indicadores = Indicadores.fromJson(json);

      expect(indicadores.ultimoPesoMedio, isNull);
      expect(indicadores.pesoPadraoG, isNull);
      expect(indicadores.gpd, isNull);
      expect(indicadores.ica, isNull);
      expect(indicadores.iep, isNull);
      expect(indicadores.classificacaoIep, isNull);
      expect(indicadores.saldoRacaoKg, isNull);
      expect(indicadores.consumoAguaDiaL, isNull);
      expect(indicadores.projecaoPeso, isNull);
    });
  });

  group('ProjecaoPeso', () {
    test('fromJson cria instancia corretamente', () {
      final json = {
        'peso_estimado_g': 2800.0,
        'data_estimada': '2025-07-15',
        'gpd_g': 52.0,
        'mensagem': 'Lote com desempenho bom',
      };

      final projecao = ProjecaoPeso.fromJson(json);

      expect(projecao.pesoEstimadoG, 2800.0);
      expect(projecao.dataEstimada, '2025-07-15');
      expect(projecao.gpdG, 52.0);
      expect(projecao.mensagem, 'Lote com desempenho bom');
    });

    test('toJson retorna mapa correto', () {
      const projecao = ProjecaoPeso(
        pesoEstimadoG: 2800.0,
        dataEstimada: '2025-07-15',
        gpdG: 52.0,
        mensagem: 'Lote com desempenho bom',
      );

      final json = projecao.toJson();

      expect(json['peso_estimado_g'], 2800.0);
      expect(json['data_estimada'], '2025-07-15');
      expect(json['gpd_g'], 52.0);
      expect(json['mensagem'], 'Lote com desempenho bom');
    });
  });
}
