import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/features/galpao/domain/entities/galpao_mapa.dart';
import '../providers/galpao_mapa_provider.dart';

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
  final Completer<GoogleMapController> _mapController = Completer();

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

    return _buildMap(granja);
  }

  Widget _buildMap(GranjaInfo granja) {
    final markers = _buildMarkers(granja.galpoes);
    final initialPosition = LatLng(granja.latitude, granja.longitude);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 17,
      ),
      markers: markers,
      mapType: MapType.hybrid,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: true,
      onMapCreated: (controller) {
        if (!_mapController.isCompleted) {
          _mapController.complete(controller);
        }
        _fitBounds(controller, granja.galpoes);
      },
    );
  }

  Set<Marker> _buildMarkers(List<GalpaoMapa> galpoes) {
    return galpoes.map((galpao) {
      final markerColor = _getMarkerHue(galpao.iot?.status);

      return Marker(
        markerId: MarkerId(galpao.id),
        position: LatLng(galpao.latitude, galpao.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
        infoWindow: InfoWindow(
          title: galpao.nome,
          snippet: _buildSnippet(galpao),
          onTap: () {
            context.pushNamed(
              RouteNames.galpaoDetalhe,
              pathParameters: {'galpaoId': galpao.id},
            );
          },
        ),
      );
    }).toSet();
  }

  String _buildSnippet(GalpaoMapa galpao) {
    final parts = <String>[];

    parts.add('${galpao.larguraM.toStringAsFixed(0)}x'
        '${galpao.comprimentoM.toStringAsFixed(0)}m');

    if (galpao.loteAtivo != null) {
      final lote = galpao.loteAtivo!;
      parts.add('${lote.avesVivas} aves - Dia ${lote.diasDeVida}');
    } else {
      parts.add('Sem lote ativo');
    }

    if (galpao.iot != null) {
      final iot = galpao.iot!;
      if (iot.temperatura != null) {
        parts.add('${iot.temperatura!.toStringAsFixed(1)} C');
      }
      if (iot.umidade != null) {
        parts.add('${iot.umidade!.toStringAsFixed(0)}% UR');
      }
    }

    return parts.join(' | ');
  }

  double _getMarkerHue(String? status) {
    switch (status) {
      case 'ok':
        return BitmapDescriptor.hueGreen;
      case 'alerta':
        return BitmapDescriptor.hueYellow;
      case 'critico':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }

  Future<void> _fitBounds(
      GoogleMapController controller, List<GalpaoMapa> galpoes) async {
    if (galpoes.length < 2) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;

    for (final galpao in galpoes) {
      if (galpao.latitude < minLat) minLat = galpao.latitude;
      if (galpao.latitude > maxLat) maxLat = galpao.latitude;
      if (galpao.longitude < minLng) minLng = galpao.longitude;
      if (galpao.longitude > maxLng) maxLng = galpao.longitude;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    // Pequeno delay para garantir que o mapa esta renderizado
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 60),
    );
  }
}
