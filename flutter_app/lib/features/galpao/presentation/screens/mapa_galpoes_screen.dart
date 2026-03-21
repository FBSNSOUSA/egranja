import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import '../providers/galpao_mapa_provider.dart';

// Importacao condicional: google_maps_flutter nao funciona na web
import 'mapa_galpoes_native.dart'
    if (dart.library.js_interop) 'mapa_galpoes_web.dart' as platform_map;

/// Tela de mapa de galpoes da granja.
///
/// Exibe um GoogleMap com marcadores para cada galpao, coloridos
/// por status de IoT. Tap no marcador exibe InfoWindow com
/// informacoes resumidas e link para detalhes.
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Galpoes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.isLoading ? null : _onRefresh,
            tooltip: 'Recarregar',
          ),
        ],
      ),
      body: _buildBody(state),
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

    return platform_map.buildMapWidget(
      context: context,
      granja: granja,
      onGalpaoTap: (galpaoId) {
        context.pushNamed(
          RouteNames.galpaoDetalhe,
          pathParameters: {'galpaoId': galpaoId},
        );
      },
    );
  }
}
