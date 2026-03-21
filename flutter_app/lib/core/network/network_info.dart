import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Wrapper de conectividade para verificar estado de rede.
///
/// Fornece:
/// - [isConnected]: verificacao pontual do estado de rede
/// - [onConnectivityChanged]: stream reativo de mudancas de conectividade
class NetworkInfo {
  final Connectivity _connectivity;
  bool _isOnline = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  NetworkInfo({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final online = !results.contains(ConnectivityResult.none);
      if (online != _isOnline) {
        _isOnline = online;
        _connectivityController.add(_isOnline);
      }
    });
  }

  /// Stream que emite `true` quando online e `false` quando offline.
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  /// Verifica se o dispositivo esta conectado a internet.
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = !results.contains(ConnectivityResult.none);
    return _isOnline;
  }

  /// Valor em cache do ultimo estado de conectividade conhecido.
  bool get isOnline => _isOnline;

  /// Libera recursos (cancelar subscription do stream).
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
