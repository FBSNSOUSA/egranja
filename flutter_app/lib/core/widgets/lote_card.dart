import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'alert_badge.dart';

/// Dados necessarios para renderizar um [LoteCard].
class LoteCardData {
  const LoteCardData({
    required this.id,
    required this.galpaoNome,
    required this.dataAlojamento,
    required this.tipo,
    required this.linhagem,
    required this.quantidadeOriginal,
    this.mortalidadeAcumulada = 0,
    this.ultimoPesoMedio,
    this.pesoBenchmark,
    this.mortesRecentes,
    this.dataMortesRecentes,
    this.mortalidadeRecentePct,
    this.temAlerta = false,
    this.quantidadeAlertas = 0,
  });

  final String id;
  final String galpaoNome;
  final DateTime dataAlojamento;
  final String tipo;
  final String linhagem;
  final int quantidadeOriginal;
  final int mortalidadeAcumulada;
  final double? ultimoPesoMedio;
  final double? pesoBenchmark;
  final int? mortesRecentes;
  final DateTime? dataMortesRecentes;
  final double? mortalidadeRecentePct;
  final bool temAlerta;
  final int quantidadeAlertas;

  /// Calcula o numero de dias desde o alojamento.
  int get diasDeVida => DateTime.now().difference(dataAlojamento).inDays;

  /// Aves vivas = original - mortalidade acumulada.
  int get avesVivas => quantidadeOriginal - mortalidadeAcumulada;

  /// Desvio percentual do peso em relacao ao benchmark.
  double? get desvioPeso {
    if (ultimoPesoMedio == null || pesoBenchmark == null || pesoBenchmark == 0) {
      return null;
    }
    return ((ultimoPesoMedio! - pesoBenchmark!) / pesoBenchmark!) * 100;
  }
}

/// Card de resumo de lote.
///
/// Exibe informacoes principais do lote: galpao, dias de vida,
/// indicadores de peso e mortalidade, e badge de alertas.
///
/// Portado do componente React Native `LoteCard.tsx`.
class LoteCard extends StatelessWidget {
  const LoteCard({
    super.key,
    required this.data,
    this.onTap,
  });

  /// Dados do lote a exibir.
  final LoteCardData data;

  /// Callback ao tocar no card.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Lote ${data.galpaoNome}, ${data.diasDeVida} dias, '
          '${data.avesVivas} aves vivas',
      child: Hero(
        tag: 'lote_${data.id}',
        child: Material(
          type: MaterialType.transparency,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
            children: [
              InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context, theme),
                      const SizedBox(height: 4),
                      _buildAlojamento(theme),
                      const Divider(height: 20),
                      _buildIndicatorsRow(theme),
                      if (data.mortesRecentes != null &&
                          data.mortesRecentes! > 0) ...[
                        const SizedBox(height: 8),
                        _buildMortalidadeRecente(theme),
                      ],
                    ],
                  ),
                ),
              ),
              // Alert badge overlay
              if (data.temAlerta && data.quantidadeAlertas > 0)
                AlertBadge(
                  count: data.quantidadeAlertas,
                  tipo: AlertBadgeTipo.critico,
                  position: AlertBadgePosition.topRight,
                ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.galpaoNome,
                style: theme.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  _Chip(label: data.tipo),
                  _Chip(label: data.linhagem),
                ],
              ),
            ],
          ),
        ),
        // Dias de vida - numero grande
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${data.diasDeVida}',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'dias',
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlojamento(ThemeData theme) {
    final dia = data.dataAlojamento.day.toString().padLeft(2, '0');
    final mes = data.dataAlojamento.month.toString().padLeft(2, '0');
    final ano = data.dataAlojamento.year;

    return Text(
      'Alojamento: $dia/$mes/$ano',
      style: theme.textTheme.labelSmall,
    );
  }

  Widget _buildIndicatorsRow(ThemeData theme) {
    return Row(
      children: [
        // Aves vivas
        Expanded(
          child: _IndicatorItem(
            label: 'Aves vivas',
            value: '${data.avesVivas}',
            theme: theme,
          ),
        ),
        // Peso medio
        Expanded(
          child: _IndicatorItem(
            label: 'Peso medio',
            value: data.ultimoPesoMedio != null
                ? '${data.ultimoPesoMedio!.toStringAsFixed(0)} g'
                : '--',
            deviation: data.desvioPeso,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildMortalidadeRecente(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: AppColors.danger,
          ),
          const SizedBox(width: 6),
          Text(
            '${data.mortesRecentes} morte${data.mortesRecentes != 1 ? 's' : ''} recente${data.mortesRecentes != 1 ? 's' : ''}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (data.mortalidadeRecentePct != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${data.mortalidadeRecentePct!.toStringAsFixed(2)}%)',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _IndicatorItem extends StatelessWidget {
  const _IndicatorItem({
    required this.label,
    required this.value,
    required this.theme,
    this.deviation,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final double? deviation;

  @override
  Widget build(BuildContext context) {
    Color? dotColor;
    if (deviation != null) {
      if (deviation! >= -5) {
        dotColor = AppColors.success;
      } else if (deviation! >= -10) {
        dotColor = AppColors.warning;
      } else {
        dotColor = AppColors.danger;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (dotColor != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (deviation != null) ...[
              const SizedBox(width: 4),
              Text(
                '${deviation! >= 0 ? '+' : ''}${deviation!.toStringAsFixed(1)}%',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: dotColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
