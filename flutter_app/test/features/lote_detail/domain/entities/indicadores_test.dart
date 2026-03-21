import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/features/lote_detail/domain/entities/indicadores.dart';

void main() {
  group('Indicadores', () {
    Map<String, dynamic> buildFullJson() {
      return {
        'dias_de_vida': 28,
        'aves_vivas': 9800,
        'quantidade_original': 10000,
        'mortalidade_acumulada': 200,
        'mortalidade_acumulada_pct': 2.0,
        'mortalidade_dia': 5,
        'mortalidade_dia_pct': 0.05,
        'ultimo_peso_medio': 1400.0,
        'peso_benchmark': 1450.0,
        'peso_desvio_pct': -3.45,
        'gpd': 50.0,
        'ica': 1.65,
        'iea': 60.6,
        'iep': 320.0,
        'iep_classificacao': 'Bom',
        'viabilidade': 98.0,
        'racao_recebida': 15000.0,
        'racao_consumida': 12000.0,
        'saldo_racao': 3000.0,
        'dias_restantes_racao': 7,
        'consumo_medio_diario_racao': 428.6,
        'consumo_agua_dia': 1500.0,
        'consumo_agua_por_ave': 153.0,
        'relacao_agua_racao': 1.8,
        'projecao_texto': 'Lote com desempenho bom',
        'peso_projetado_abate': 2800.0,
        'dias_para_peso_alvo': 14,
      };
    }

    test('fromJson cria instancia com todos os campos', () {
      final json = buildFullJson();

      final indicadores = Indicadores.fromJson(json);

      expect(indicadores.diasDeVida, 28);
      expect(indicadores.avesVivas, 9800);
      expect(indicadores.quantidadeOriginal, 10000);
      expect(indicadores.mortalidadeAcumulada, 200);
      expect(indicadores.mortalidadeAcumuladaPct, 2.0);
      expect(indicadores.mortalidadeDia, 5);
      expect(indicadores.mortalidadeDiaPct, 0.05);
      expect(indicadores.ultimoPesoMedio, 1400.0);
      expect(indicadores.pesoBenchmark, 1450.0);
      expect(indicadores.pesoDesvioPct, -3.45);
      expect(indicadores.gpd, 50.0);
      expect(indicadores.ica, 1.65);
      expect(indicadores.iea, 60.6);
      expect(indicadores.iep, 320.0);
      expect(indicadores.iepClassificacao, 'Bom');
      expect(indicadores.viabilidade, 98.0);
      expect(indicadores.racaoRecebida, 15000.0);
      expect(indicadores.racaoConsumida, 12000.0);
      expect(indicadores.saldoRacao, 3000.0);
      expect(indicadores.diasRestantesRacao, 7);
      expect(indicadores.consumoMedioDiarioRacao, 428.6);
      expect(indicadores.consumoAguaDia, 1500.0);
      expect(indicadores.consumoAguaPorAve, 153.0);
      expect(indicadores.relacaoAguaRacao, 1.8);
      expect(indicadores.projecaoTexto, 'Lote com desempenho bom');
      expect(indicadores.pesoProjetadoAbate, 2800.0);
      expect(indicadores.diasParaPesoAlvo, 14);
    });

    test('toJson retorna mapa correto', () {
      final json = buildFullJson();
      final indicadores = Indicadores.fromJson(json);
      final result = indicadores.toJson();

      expect(result, json);
    });

    test('fromJson/toJson round-trip preserva dados', () {
      final original = buildFullJson();

      final indicadores = Indicadores.fromJson(original);
      final result = indicadores.toJson();

      expect(result, original);
    });

    test('fromJson aceita valores inteiros para campos double', () {
      final json = buildFullJson();
      // Sobrescrever com int para validar que num.toDouble() funciona
      json['ultimo_peso_medio'] = 1400;
      json['peso_benchmark'] = 1450;
      json['gpd'] = 50;

      final indicadores = Indicadores.fromJson(json);

      expect(indicadores.ultimoPesoMedio, 1400.0);
      expect(indicadores.pesoBenchmark, 1450.0);
      expect(indicadores.gpd, 50.0);
    });
  });
}
