import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:egranja_flutter/features/galpao/domain/entities/galpao_mapa.dart';

/// Constroi o widget de mapa usando GoogleMap nativo (Android/iOS).
Widget buildMapWidget({
  required BuildContext context,
  required GranjaInfo granja,
  required void Function(String galpaoId) onGalpaoTap,
}) {
  return _NativeMapWidget(
    granja: granja,
    onGalpaoTap: onGalpaoTap,
  );
}

class _NativeMapWidget extends StatefulWidget {
  const _NativeMapWidget({
    required this.granja,
    required this.onGalpaoTap,
  });

  final GranjaInfo granja;
  final void Function(String galpaoId) onGalpaoTap;

  @override
  State<_NativeMapWidget> createState() => _NativeMapWidgetState();
}

class _NativeMapWidgetState extends State<_NativeMapWidget> {
  final Completer<GoogleMapController> _mapController = Completer();

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers(widget.granja.galpoes);
    final initialPosition = LatLng(
      widget.granja.latitude,
      widget.granja.longitude,
    );

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
        _fitBounds(controller, widget.granja.galpoes);
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
          onTap: () => widget.onGalpaoTap(galpao.id),
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

    await Future<void>.delayed(const Duration(milliseconds: 300));
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
  }
}
