import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Dados necessarios para renderizar um [LoteCard].
///
/// Campos opcionais correspondem a dados que o backend pode ou nao
/// retornar no endpoint de listagem de lotes.
class LoteCardData {
  const LoteCardData({
    required this.id,
    required this.galpaoNome,
    required this.dataAlojamento,
    required this.tipo,
    required this.linhagem,
    required this.quantidadeOriginal,
    this.mortalidadeAcumulada = 0,
    this.diasDeVida,
    this.avesVivas,
    this.ultimoPesoMedio,
    this.status = 'ativo',
  });

  final String id;
  final String galpaoNome;
  final DateTime dataAlojamento;
  final String tipo;
  final String linhagem;
  final int quantidadeOriginal;
  final int mortalidadeAcumulada;

  /// Status do lote: 'ativo' ou 'finalizado'.
  final String status;

  /// Dias de vida retornados pelo backend (campo `dias_de_vida`).
  /// Quando nulo, calcula a partir da data de alojamento.
  final int? diasDeVida;

  /// Aves vivas retornadas pelo backend (campo `aves_vivas`).
  /// Quando nulo, calcula a partir de quantidadeOriginal - mortalidadeAcumulada.
  final int? avesVivas;

  /// Ultimo peso medio registrado em gramas (campo `ultimo_peso_medio`).
  final double? ultimoPesoMedio;

  /// Dias de vida efetivo: usa o valor do backend ou calcula localmente.
  int get diasDeVidaEfetivo =>
      diasDeVida ?? DateTime.now().difference(dataAlojamento).inDays;

  /// Aves vivas efetivo: usa o valor do backend ou calcula localmente.
  int get avesVivasEfetivo =>
      avesVivas ?? (quantidadeOriginal - mortalidadeAcumulada);

  /// Mortalidade percentual acumulada.
  double get mortalidadePct {
    if (quantidadeOriginal <= 0) return 0;
    return (mortalidadeAcumulada / quantidadeOriginal) * 100;
  }

  /// Se o lote esta ativo.
  bool get isAtivo => status == 'ativo';

  /// Mortalidade esta em nivel critico (>3% acumulada ou media diaria >0.1%).
  bool get mortalidadeCritica {
    final pct = mortalidadePct;
    if (pct > 3.0) return true;
    final dias = diasDeVidaEfetivo;
    if (dias > 0 && (pct / dias) > 0.1) return true;
    return false;
  }
}

/// Card de resumo de lote.
///
/// Exibe informacoes principais do lote: galpao, dias de vida,
/// indicadores de peso e mortalidade, e badge de status.
/// Otimizado para leitura rapida no campo com hierarquia visual clara,
/// cores semanticas para mortalidade e touch targets grandes (48dp+).
///
/// Portado do componente React Native `LoteCard.tsx`.
class LoteCard extends StatelessWidget {
  const LoteCard({
    super.key,
    required this.data,
    this.onTap,
    this.onPesagem,
    this.onMortalidade,
  });

  /// Dados do lote a exibir.
  final LoteCardData data;

  /// Callback ao tocar no card.
  final VoidCallback? onTap;

  /// Atalho para registrar pesagem diretamente do card.
  final VoidCallback? onPesagem;

  /// Atalho para registrar mortalidade diretamente do card.
  final VoidCallback? onMortalidade;

  /// Cor semantica da mortalidade para destaque visual.
  Color _getMortalidadeColor() {
    final pct = data.mortalidadePct;
    if (pct > 5) return AppColors.danger;
    if (pct > 3) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Lote ${data.galpaoNome}, ${data.diasDeVidaEfetivo} dias, '
          '${data.avesVivasEfetivo} aves vivas, '
          'mortalidade ${data.mortalidadePct.toStringAsFixed(1)} por cento',
      button: true,
      child: Hero(
        tag: 'lote_${data.id}',
        child: Material(
          type: MaterialType.transparency,
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: data.isAtivo ? 2 : 0.5,
            child: Stack(
              children: [
                // Left accent bar showing mortality status
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    color: data.isAtivo
                        ? _getMortalidadeColor()
                        : AppColors.gray400,
                  ),
                ),
                InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, theme),
                        const SizedBox(height: 4),
                        _buildAlojamento(theme),
                        const Divider(height: 20),
                        _buildIndicatorsRow(theme),
                        // Quick action buttons for active lotes
                        if (data.isAtivo &&
                            (onPesagem != null || onMortalidade != null))
                          _buildQuickActions(theme),
                      ],
                    ),
                  ),
                ),
                // Status badge for finished lotes
                if (!data.isAtivo)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Finalizado',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
        // Dias de vida - numero grande e proeminente
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: data.isAtivo
                ? theme.colorScheme.primaryContainer.withAlpha(80)
                : AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${data.diasDeVidaEfetivo}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: data.isAtivo
                      ? theme.colorScheme.primary
                      : AppColors.gray600,
                ),
              ),
              Text(
                'dias',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: data.isAtivo
                      ? theme.colorScheme.primary
                      : AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlojamento(ThemeData theme) {
    final dia = data.dataAlojamento.day.toString().padLeft(2, '0');
    final mes = data.dataAlojamento.month.toString().padLeft(2, '0');
    final ano = data.dataAlojamento.year;

    return Row(
      children: [
        Icon(
          Icons.event_outlined,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          'Alojamento: $dia/$mes/$ano',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildIndicatorsRow(ThemeData theme) {
    return Row(
      children: [
        // Aves vivas / alojadas
        Expanded(
          child: _IndicatorItem(
            icon: Icons.pets,
            label: 'Aves vivas',
            value: _formatNumber(data.avesVivasEfetivo),
            subtitle: 'de ${_formatNumber(data.quantidadeOriginal)}',
            theme: theme,
          ),
        ),
        // Mortalidade % - color coded (indicador critico na avicultura)
        Expanded(
          child: _IndicatorItem(
            icon: data.mortalidadeCritica
                ? Icons.error_outline
                : Icons.warning_amber,
            label: 'Mort. %',
            value: '${data.mortalidadePct.toStringAsFixed(2)}%',
            subtitle: '${data.mortalidadeAcumulada} mortes',
            theme: theme,
            valueColor: _getMortalidadeColor(),
          ),
        ),
        // Ultimo peso medio (fundamental para acompanhar o lote)
        Expanded(
          child: _IndicatorItem(
            icon: Icons.monitor_weight_outlined,
            label: 'Peso medio',
            value: data.ultimoPesoMedio != null
                ? '${data.ultimoPesoMedio!.toStringAsFixed(0)} g'
                : '--',
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          if (onPesagem != null)
            Expanded(
              child: _QuickActionButton(
                icon: Icons.monitor_weight_outlined,
                label: 'Pesagem',
                onTap: onPesagem!,
                theme: theme,
              ),
            ),
          if (onPesagem != null && onMortalidade != null)
            const SizedBox(width: 8),
          if (onMortalidade != null)
            Expanded(
              child: _QuickActionButton(
                icon: Icons.warning_amber_rounded,
                label: 'Mortalidade',
                onTap: onMortalidade!,
                theme: theme,
                isDestructive: true,
              ),
            ),
        ],
      ),
    );
  }

  /// Formata numeros grandes com separador de milhar para leitura rapida.
  String _formatNumber(int value) {
    if (value < 1000) return '$value';
    final thousands = value ~/ 1000;
    final remainder = value % 1000;
    if (remainder == 0) return '${thousands}k';
    final hundredths = remainder ~/ 100;
    return '$thousands.${hundredths}k';
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

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.theme,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeData theme;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.danger : theme.colorScheme.primary;

    return Material(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndicatorItem extends StatelessWidget {
  const _IndicatorItem({
    required this.label,
    required this.value,
    required this.theme,
    this.icon,
    this.valueColor,
    this.subtitle,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final IconData? icon;
  final Color? valueColor;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: valueColor ?? theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
