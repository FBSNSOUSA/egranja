import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../di/providers.dart';
import '../sync/sync_state.dart';
import '../theme/app_colors.dart';

/// Banner indicador de estado de conectividade e sincronizacao.
///
/// Observa via Riverpod os providers de conectividade e sincronizacao
/// para exibir/ocultar automaticamente um banner colorido:
/// - Laranja: dispositivo offline
/// - Azul: sincronizando ou com operacoes pendentes
/// - Oculto: online sem operacoes pendentes
///
/// Portado do componente React Native `OfflineIndicator.tsx`.
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final syncState = ref.watch(syncProvider);

    final isOnline = connectivityAsync.when(
      data: (online) => online,
      loading: () => true,
      error: (_, _) => true,
    );

    // Determinar estado visual
    final _BannerState bannerState;

    if (!isOnline) {
      bannerState = _BannerState(
        visible: true,
        color: AppColors.offline,
        icon: Icons.wifi_off_outlined,
        message: 'Sem conexao com a internet',
        hint: 'Os dados serao sincronizados quando a conexao retornar',
      );
    } else if (syncState.isSyncing) {
      bannerState = _BannerState(
        visible: true,
        color: AppColors.syncing,
        icon: Icons.sync_outlined,
        message: 'Sincronizando dados...',
        hint: null,
      );
    } else if (syncState.pendingCount > 0) {
      bannerState = _BannerState(
        visible: true,
        color: AppColors.syncing,
        icon: Icons.cloud_upload_outlined,
        message:
            '${syncState.pendingCount} operacao${syncState.pendingCount != 1 ? 'oes' : ''} pendente${syncState.pendingCount != 1 ? 's' : ''}',
        hint: 'Toque para sincronizar',
      );
    } else {
      bannerState = _BannerState(
        visible: false,
        color: Colors.transparent,
        icon: Icons.check,
        message: '',
        hint: null,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: bannerState.visible ? null : 0,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: bannerState.visible
          ? Material(
              color: bannerState.color,
              child: InkWell(
                onTap: isOnline && syncState.pendingCount > 0
                    ? () => ref.read(syncProvider.notifier).triggerSync()
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        bannerState.icon,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              bannerState.message,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (bannerState.hint != null)
                              Text(
                                bannerState.hint!,
                                style: TextStyle(
                                  color: AppColors.white.withAlpha(200),
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

/// Estado interno do banner.
class _BannerState {
  const _BannerState({
    required this.visible,
    required this.color,
    required this.icon,
    required this.message,
    required this.hint,
  });

  final bool visible;
  final Color color;
  final IconData icon;
  final String message;
  final String? hint;
}
