import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../router/route_names.dart';
import '../sync/sync_state.dart';
import '../theme/app_colors.dart';

/// Shell principal do app: Scaffold com AppBar + Drawer.
///
/// Usado como wrapper do [ShellRoute] do GoRouter para manter o Drawer
/// persistente em todas as telas autenticadas.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('eGranja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notificacoes',
            onPressed: () {
              // TODO: implementar tela de notificacoes
            },
          ),
        ],
      ),
      drawer: _AppDrawer(ref: ref),
      body: child,
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.ref});

  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final userInitial = (user?.nome.isNotEmpty == true)
        ? user!.nome[0].toUpperCase()
        : 'U';
    final userName = user?.nome ?? 'Usuario';
    final userEmail = user?.login ?? '';

    return Semantics(
      label: 'Menu de navegacao',
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Semantics(
              label: 'Perfil: $userName, $userEmail',
              child: DrawerHeader(
                decoration: const BoxDecoration(color: AppColors.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ExcludeSemantics(
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.white,
                        child: Text(
                          userInitial,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.8),
                          ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Navegacao principal ──────────────────────────────────────
          _DrawerItem(
            icon: Icons.home_outlined,
            label: 'Inicio',
            onTap: () => _navigate(context, RouteNames.home),
          ),
          _DrawerItem(
            icon: Icons.inventory_2_outlined,
            label: 'Novo Lote',
            onTap: () => _navigate(context, RouteNames.novoLote),
          ),
          _DrawerItem(
            icon: Icons.checklist_outlined,
            label: 'Checklist Diario',
            onTap: () => _navigate(context, RouteNames.checklist),
          ),

          const Divider(),

          // ── Sanidade ────────────────────────────────────────────────
          _DrawerItem(
            icon: Icons.vaccines_outlined,
            label: 'Vacinacoes',
            onTap: () => _navigate(context, RouteNames.vacinacoes),
          ),
          _DrawerItem(
            icon: Icons.medication_outlined,
            label: 'Medicamentos',
            onTap: () => _navigate(context, RouteNames.medicamentos),
          ),
          _DrawerItem(
            icon: Icons.badge_outlined,
            label: 'Visitantes',
            onTap: () => _navigate(context, RouteNames.visitantes),
          ),

          const Divider(),

          // ── Financeiro ──────────────────────────────────────────────
          _DrawerItem(
            icon: Icons.attach_money_outlined,
            label: 'Financeiro',
            onTap: () => _navigate(context, RouteNames.financeiroResumo),
          ),

          // ── Comunicacao ─────────────────────────────────────────────
          _DrawerItem(
            icon: Icons.chat_outlined,
            label: 'Mensagens',
            onTap: () => _navigate(context, RouteNames.chatList),
          ),

          const Divider(),

          // ── Analise ─────────────────────────────────────────────────
          _DrawerItem(
            icon: Icons.bar_chart_outlined,
            label: 'Relatorios',
            onTap: () => _navigate(context, RouteNames.relatorios),
          ),
          _DrawerItem(
            icon: Icons.smart_toy_outlined,
            label: 'IA Assistente',
            onTap: () => _navigate(context, RouteNames.iaAssistente),
          ),
          _DrawerItem(
            icon: Icons.sensors_outlined,
            label: 'IoT Sensores',
            onTap: () => _navigate(context, RouteNames.iotDashboard),
          ),
          _DrawerItem(
            icon: Icons.cloud_outlined,
            label: 'Clima',
            onTap: () => _navigate(context, RouteNames.clima),
          ),
          _DrawerItem(
            icon: Icons.map_outlined,
            label: 'Mapa Galpoes',
            onTap: () => _navigate(context, RouteNames.mapaGalpoes),
          ),

          const Divider(),

          // ── Configuracoes & Sair ────────────────────────────────────
          _DrawerItem(
            icon: Icons.settings_outlined,
            label: 'Configuracoes',
            onTap: () => _navigate(context, RouteNames.configuracoes),
          ),
          _DrawerItem(
            icon: Icons.logout,
            label: 'Sair',
            iconColor: AppColors.danger,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
      ),
    );
  }

  void _navigate(BuildContext context, String routeName) {
    Navigator.of(context).pop(); // fecha drawer
    context.goNamed(routeName);
  }

  void _handleLogout(BuildContext context) {
    Navigator.of(context).pop(); // fecha drawer

    // Tenta ler pendingCount do syncProvider
    int pendingCount = 0;
    try {
      final syncState = ref.read(syncProvider);
      pendingCount = syncState.pendingCount;
    } catch (_) {
      // syncProvider nao disponivel
    }

    if (pendingCount > 0) {
      showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Operacoes pendentes'),
          content: Text(
            'Voce tem $pendingCount '
            '${pendingCount == 1 ? 'operacao pendente' : 'operacoes pendentes'}. '
            'Deseja sair mesmo assim?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
                ref.read(authNotifierProvider.notifier).logout();
              },
              child: const Text('Sair'),
            ),
          ],
        ),
      );
    } else {
      ref.read(authNotifierProvider.notifier).logout();
    }
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.gray700),
      title: Text(label),
      onTap: onTap,
      dense: true,
    );
  }
}
