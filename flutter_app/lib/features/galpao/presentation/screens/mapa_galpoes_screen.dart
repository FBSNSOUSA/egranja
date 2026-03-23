import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/features/galpao/domain/entities/galpao_mapa.dart';
import '../providers/galpao_mapa_provider.dart';

/// Tela de mapa de galpoes da granja.
///
/// Exibe galpoes em um layout de cards com status, informacoes resumidas
/// de IoT e lote ativo. Cada card permite navegar para os detalhes do galpao.
///
/// Se coordenadas validas estiverem disponiveis e a plataforma suportar,
/// exibe um GoogleMap com marcadores. Caso contrario, usa um layout
/// esquematico de cards.
class MapaGalpoesScreen extends ConsumerStatefulWidget {
  const MapaGalpoesScreen({super.key});

  @override
  ConsumerState<MapaGalpoesScreen> createState() => _MapaGalpoesScreenState();
}

class _MapaGalpoesScreenState extends ConsumerState<MapaGalpoesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(galpaoMapaProvider.notifier).fetch();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(galpaoMapaProvider.notifier).fetch();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galpaoMapaProvider);

    return Column(
      children: [
        // Barra de acoes (anteriormente no AppBar)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: state.isLoading ? null : _onRefresh,
                tooltip: 'Recarregar',
              ),
            ],
          ),
        ),

        // Conteudo principal
        Expanded(child: _buildBody(state)),
      ],
    );
  }

  Widget _buildBody(GalpaoMapaState state) {
    if (state.isLoading && state.granja == null) {
      return const SkeletonList(itemCount: 3);
    }

    if (state.errorMessage != null && state.granja == null) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: _onRefresh,
      );
    }

    final granja = state.granja;
    if (granja == null || granja.galpoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.warehouse_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum galpao cadastrado.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    // Usar layout esquematico de cards (funciona em todas as plataformas)
    return _buildSchematicView(granja);
  }

  /// Layout esquematico de cards mostrando galpoes com status e indicadores.
  Widget _buildSchematicView(GranjaInfo granja) {
    final theme = Theme.of(context);
    final galpoes = granja.galpoes;

    // Contar estatisticas
    final comLote = galpoes.where((g) => g.loteAtivo != null).length;
    final comIoT = galpoes.where((g) => g.iot != null).length;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumo
          _buildSummaryRow(theme, galpoes.length, comLote, comIoT),
          const SizedBox(height: 16),

          // Grid de galpoes
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: galpoes.length,
            itemBuilder: (context, index) {
              return _GalpaoSchematicCard(
                galpao: galpoes[index],
                onTap: () {
                  context.pushNamed(
                    RouteNames.galpaoDetalhe,
                    pathParameters: {'galpaoId': galpoes[index].id},
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(ThemeData theme, int total, int comLote, int comIoT) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SummaryChip(
              icon: Icons.warehouse_outlined,
              label: 'Total',
              value: total.toString(),
              color: AppColors.tertiary,
            ),
            _SummaryChip(
              icon: Icons.egg_outlined,
              label: 'Com Lote',
              value: comLote.toString(),
              color: AppColors.success,
            ),
            _SummaryChip(
              icon: Icons.sensors,
              label: 'Com IoT',
              value: comIoT.toString(),
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Card esquematico de galpao ──────────────────────────────────────────

class _GalpaoSchematicCard extends StatelessWidget {
  const _GalpaoSchematicCard({
    required this.galpao,
    required this.onTap,
  });

  final GalpaoMapa galpao;
  final VoidCallback onTap;

  Color _statusColor() {
    if (galpao.iot != null) {
      switch (galpao.iot!.status) {
        case 'ok':
          return AppColors.success;
        case 'alerta':
          return AppColors.warning;
        case 'critico':
          return AppColors.danger;
      }
    }
    if (galpao.loteAtivo != null) return AppColors.success;
    return AppColors.gray400;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor();
    final hasLote = galpao.loteAtivo != null;
    final hasIoT = galpao.iot != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black.withAlpha(15),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Barra de status
            Container(height: 4, color: color),

            // Icone do galpao (esquema visual)
            Expanded(
              flex: 3,
              child: Container(
                color: color.withAlpha(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Retangulo representando o galpao
                    Container(
                      width: 60,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: color, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: color.withAlpha(30),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warehouse,
                            size: 28,
                            color: color,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${galpao.larguraM.toStringAsFixed(0)}x${galpao.comprimentoM.toStringAsFixed(0)}m',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Indicador de orientacao
                    if (galpao.orientacaoGraus > 0)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(200),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.explore,
                                  size: 10, color: AppColors.gray500),
                              const SizedBox(width: 2),
                              Text(
                                '${galpao.orientacaoGraus.toStringAsFixed(0)}\u00B0',
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppColors.gray600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Informacoes
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    Text(
                      galpao.nome,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Ventilacao
                    if (galpao.ventilacao.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.air, size: 12, color: AppColors.gray500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              galpao.ventilacao,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 4),

                    // Status do lote
                    if (hasLote) ...[
                      Row(
                        children: [
                          Icon(Icons.egg, size: 12, color: AppColors.success),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${galpao.loteAtivo!.avesVivas} aves',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 12, color: AppColors.gray500),
                          const SizedBox(width: 4),
                          Text(
                            'Dia ${galpao.loteAtivo!.diasDeVida}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        'Sem lote ativo',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.gray500,
                          fontStyle: FontStyle.italic,
                          fontSize: 10,
                        ),
                      ),

                    const Spacer(),

                    // IoT
                    if (hasIoT)
                      Row(
                        children: [
                          if (galpao.iot!.temperatura != null) ...[
                            Icon(Icons.thermostat,
                                size: 12, color: AppColors.warning),
                            const SizedBox(width: 2),
                            Text(
                              '${galpao.iot!.temperatura!.toStringAsFixed(1)}\u00B0',
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (galpao.iot!.umidade != null) ...[
                            Icon(Icons.water_drop,
                                size: 12, color: AppColors.tertiary),
                            const SizedBox(width: 2),
                            Text(
                              '${galpao.iot!.umidade!.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Chip de resumo ──────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
