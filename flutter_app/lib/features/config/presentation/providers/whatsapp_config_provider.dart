import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/auth/secure_storage_native.dart'
    if (dart.library.js_interop) 'package:egranja_flutter/core/auth/secure_storage_web.dart'
    as platform_storage;

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado do numero de WhatsApp do integrador.
class WhatsAppConfigState {
  final String phone;
  final bool isSaving;

  const WhatsAppConfigState({
    this.phone = '',
    this.isSaving = false,
  });

  WhatsAppConfigState copyWith({
    String? phone,
    bool? isSaving,
  }) {
    return WhatsAppConfigState(
      phone: phone ?? this.phone,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WhatsAppConfigState &&
          runtimeType == other.runtimeType &&
          phone == other.phone &&
          isSaving == other.isSaving;

  @override
  int get hashCode => Object.hash(phone, isSaving);
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador do numero de WhatsApp do integrador.
///
/// Armazena o numero localmente usando o mesmo mecanismo de storage
/// seguro (FlutterSecureStorage no mobile, localStorage na web).
class WhatsAppConfigNotifier extends StateNotifier<WhatsAppConfigState> {
  static const String _storageKey = 'egranja_whatsapp_integrador';

  WhatsAppConfigNotifier() : super(const WhatsAppConfigState()) {
    _loadFromStorage();
  }

  /// Carrega o numero armazenado.
  Future<void> _loadFromStorage() async {
    try {
      final saved = await platform_storage.read(key: _storageKey);
      if (!mounted) return;
      if (saved != null && saved.isNotEmpty) {
        state = state.copyWith(phone: saved);
      }
    } catch (e) {
      debugPrint('[WhatsAppConfig] Erro ao carregar numero: $e');
    }
  }

  /// Salva o numero do integrador.
  Future<void> salvarNumero(String phone) async {
    state = state.copyWith(isSaving: true);

    try {
      final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
      await platform_storage.write(key: _storageKey, value: cleanPhone);
      if (!mounted) return;
      state = state.copyWith(phone: cleanPhone, isSaving: false);
    } catch (e) {
      debugPrint('[WhatsAppConfig] Erro ao salvar numero: $e');
      if (!mounted) return;
      state = state.copyWith(isSaving: false);
    }
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [WhatsAppConfigNotifier].
final whatsappConfigProvider =
    StateNotifierProvider<WhatsAppConfigNotifier, WhatsAppConfigState>(
  (ref) => WhatsAppConfigNotifier(),
);
