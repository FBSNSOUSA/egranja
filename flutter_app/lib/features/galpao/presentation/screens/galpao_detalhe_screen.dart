import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/features/galpao/domain/entities/galpao_detalhe.dart';
import '../providers/galpao_detalhe_provider.dart';
import '../widgets/galpao_wind_sun_view.dart';

/// Tela de detalhe de um galpao.
///
/// Exibe informacoes gerais, localizacao, visualizacao de vento/sol,
/// lote ativo e historico de lotes.
class GalpaoDetalheScreen extends ConsumerStatefulWidget {
  const GalpaoDetalheScreen({super.key, required this.galpaoId});

  final String galpaoId;

  @override
  ConsumerState<GalpaoDetalheScreen> createState() =>
      _GalpaoDetalheScreenState();
}

class _GalpaoDetalheScreenState extends ConsumerState<GalpaoDetalheScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(galpaoDetalheProvider(widget.galpaoId).notifier).fetch();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(galpaoDetalheProvider(widget.galpaoId).notifier).fetch();
  }

  Future<void> _openInGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galpaoDetalheProvider(widget.galpaoId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.galpao?.nome ?? 'Galpao'),
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(GalpaoDetalheState state, ThemeData theme) {
    if (state.isLoading && state.galpao == null) {
      return const SkeletonList(itemCount: 4);
    }

    if (state.errorMessage != null && state.galpao == null) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: _onRefresh,
      );
    }

    final galpao = state.galpao;
    if (galpao == null) {
      return const Center(
        child: Text('Nenhum dado disponivel.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(galpao, theme),
          const SizedBox(height: 16),
          _buildLocationCard(galpao, theme),
          const SizedBox(height: 16),
          if (galpao.clima != null) ...[
            _buildWindSunCard(galpao, theme),
            const SizedBox(height: 16),
          ],
          if (galpao.loteAtivo != null) ...[
            _buildLoteAtivoCard(galpao.loteAtivo!, theme),
            const SizedBox(height: 16),
          ],
          if (galpao.lotesFinalizados.isNotEmpty) ...[
            _buildLoteHistoricoSection(galpao.lotesFinalizados, theme),
          ],
        ],
      ),
    );
  }

  /// Card com informacoes gerais do galpao.
  Widget _buildInfoCard(GalpaoDetalhe galpao, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warehouse_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Informacoes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow(
              theme,
              'Dimensoes',
              '${galpao.larguraM.toStringAsFixed(1)} x '
                  '${galpao.comprimentoM.toStringAsFixed(1)} m',
              Icons.straighten,
            ),
            _infoRow(
              theme,
              'Orientacao',
              galpao.orientacaoTexto.isNotEmpty
                  ? '${galpao.orientacaoTexto} (${galpao.orientacaoGraus.toStringAsFixed(0)})'
                  : galpao.orientacaoGraus.toStringAsFixed(0),
              Icons.explore,
            ),
            _infoRow(
              theme,
              'Ventilacao',
              galpao.ventilacao.isNotEmpty ? galpao.ventilacao : '-',
              Icons.air,
            ),
            _infoRow(
              theme,
              'Cortinas',
              galpao.cortinas.isNotEmpty ? galpao.cortinas : '-',
              Icons.curtains,
            ),
            _infoRow(
              theme,
              'Capacidade',
              galpao.capacidade > 0
                  ? '${galpao.capacidade} aves'
                  : '-',
              Icons.groups,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(
      ThemeData theme, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.gray500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Card de localizacao com coordenadas e botao para Google Maps.
  Widget _buildLocationCard(GalpaoDetalhe galpao, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Localizacao',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _infoRow(
              theme,
              'Latitude',
              galpao.latitude.toStringAsFixed(6),
              Icons.gps_fixed,
            ),
            _infoRow(
              theme,
              'Longitude',
              galpao.longitude.toStringAsFixed(6),
              Icons.gps_fixed,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    _openInGoogleMaps(galpao.latitude, galpao.longitude),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Abrir no Google Maps'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card com visualizacao de vento e sol.
  Widget _buildWindSunCard(GalpaoDetalhe galpao, ThemeData theme) {
    final clima = galpao.clima!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wb_sunny_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Vento e Sol',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Center(
              child: GalpaoWindSunView(
                largura: galpao.larguraM,
                comprimento: galpao.comprimentoM,
                orientacaoGraus: galpao.orientacaoGraus,
                ventoVelocidade: clima.ventoVelocidade,
                ventoDirecao: clima.ventoDirecao,
                temperaturaExterna: clima.temperaturaExterna,
                cortinasAbertas: galpao.cortinasAbertas,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card do lote ativo.
  Widget _buildLoteAtivoCard(LoteHistorico lote, ThemeData theme) {
    return Card(
      color: AppColors.successLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.egg_outlined, color: AppColors.success),
                const SizedBox(width: 8),
                Text(
                  'Lote Ativo',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Ativo',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Alojamento: ${lote.dataAlojamento}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Quantidade: ${lote.quantidade} aves',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.pushNamed(
                    RouteNames.loteDetail,
                    pathParameters: {'loteId': lote.id},
                  );
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Ver detalhes do lote'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Secao de historico de lotes finalizados.
  Widget _buildLoteHistoricoSection(
      List<LoteHistorico> lotes, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historico de Lotes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...lotes.map((lote) => _buildLoteHistoricoCard(lote, theme)),
      ],
    );
  }

  Widget _buildLoteHistoricoCard(LoteHistorico lote, ThemeData theme) {
    final periodo = lote.dataFinalizacao != null
        ? '${lote.dataAlojamento} - ${lote.dataFinalizacao}'
        : lote.dataAlojamento;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.history, color: AppColors.gray500),
        title: Text(periodo, style: theme.textTheme.bodyMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alojadas: ${lote.quantidade}'),
            if (lote.avesEntregues != null)
              Text('Entregues: ${lote.avesEntregues}'),
            Row(
              children: [
                if (lote.mortalidadePct != null) ...[
                  Text(
                    'Mort.: ${lote.mortalidadePct!.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: lote.mortalidadePct! > 5
                          ? AppColors.danger
                          : AppColors.success,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                if (lote.pesoMedioFinal != null)
                  Text(
                    'Peso: ${lote.pesoMedioFinal!.toStringAsFixed(3)} kg',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          context.pushNamed(
            RouteNames.loteDetail,
            pathParameters: {'loteId': lote.id},
          );
        },
      ),
    );
  }
}
