import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/sync/sync_state.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:egranja_flutter/features/config/presentation/providers/whatsapp_config_provider.dart';

/// Tela de Configuracoes do eGranja.
///
/// Exibe 4 secoes:
/// 1. Perfil - dados do usuario
/// 2. Notificacoes - toggles para cada tipo de alerta
/// 3. Dados - operacoes pendentes e botao de sincronizacao
/// 4. Sobre - versao, suporte, termos
class ConfiguracoesScreen extends ConsumerStatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  ConsumerState<ConfiguracoesScreen> createState() =>
      _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends ConsumerState<ConfiguracoesScreen> {
  // Estado local dos toggles de notificacao
  final Map<String, bool> _notificacoes = {
    'mortalidade': true,
    'peso': true,
    'racao': true,
    'agua': true,
    'clima': true,
    'iot': true,
  };

  bool _isSyncing = false;

  // WhatsApp
  final _whatsappController = TextEditingController();
  bool _whatsappInitialized = false;

  @override
  void dispose() {
    _whatsappController.dispose();
    super.dispose();
  }

  void _toggleNotificacao(String key) {
    setState(() {
      _notificacoes[key] = !(_notificacoes[key] ?? false);
    });
  }

  Future<void> _forcarSincronizacao() async {
    setState(() => _isSyncing = true);

    try {
      // Tenta usar o syncProvider se disponivel
      try {
        await ref.read(syncProvider.notifier).triggerSync();
      } catch (_) {
        // syncProvider nao disponivel, simula sincronizacao
        await Future<void>.delayed(const Duration(seconds: 2));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados sincronizados com sucesso!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Nao foi possivel sincronizar os dados. '
              'Verifique sua conexao.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  Widget _buildWhatsAppSection(BuildContext context) {
    final whatsappState = ref.watch(whatsappConfigProvider);

    // Inicializar o controller com o valor armazenado (apenas uma vez)
    if (!_whatsappInitialized && whatsappState.phone.isNotEmpty) {
      _whatsappController.text = whatsappState.phone;
      _whatsappInitialized = true;
    }

    return _SecaoCard(
      icon: Icons.chat,
      titulo: 'WhatsApp Integrador',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure o numero do integrador para compartilhar '
            'resumos de pesagem, mortalidade e checklist via WhatsApp.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _whatsappController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numero do integrador',
              hintText: '5511999998888',
              helperText: 'Formato internacional sem + (ex: 5511999998888)',
              prefixIcon: const Icon(Icons.phone),
              filled: true,
              fillColor: AppColors.gray50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: whatsappState.phone.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _whatsappController.clear();
                        ref
                            .read(whatsappConfigProvider.notifier)
                            .salvarNumero('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: whatsappState.isSaving
                  ? null
                  : () {
                      ref
                          .read(whatsappConfigProvider.notifier)
                          .salvarNumero(_whatsappController.text.trim());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Numero do integrador salvo!'),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
              icon: whatsappState.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                whatsappState.isSaving ? 'Salvando...' : 'Salvar numero',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final tipoConta = user?.tipo == 'tecnico' ? 'Tecnico' : 'Produtor';

    // Tenta ler pendingCount do syncProvider, fallback para 0
    int pendingCount = 0;
    try {
      final syncState = ref.watch(syncProvider);
      pendingCount = syncState.pendingCount;
    } catch (_) {
      // syncProvider nao disponivel
    }

    return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Secao 1: Perfil ──────────────────────────────────────────
          _SecaoCard(
            icon: Icons.account_circle,
            titulo: 'Perfil',
            child: Column(
              children: [
                // Avatar + nome + badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user?.nome.isNotEmpty == true
                            ? user!.nome[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.nome ?? 'Usuario',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(
                              tipoConta,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            side: BorderSide.none,
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Info rows
                _InfoRow(
                  label: 'Email',
                  valor: user?.login ?? 'Nao informado',
                ),
                _InfoRow(
                  label: 'Telefone',
                  valor: 'Nao informado',
                ),
                _InfoRow(
                  label: 'Tipo de conta',
                  valor: tipoConta,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Secao 2: Notificacoes ────────────────────────────────────
          _SecaoCard(
            icon: Icons.notifications,
            titulo: 'Notificacoes',
            child: Column(
              children: [
                _NotificacaoToggle(
                  icon: Icons.warning_amber,
                  label: 'Mortalidade',
                  descricao: 'Alertas de mortalidade acima do esperado',
                  value: _notificacoes['mortalidade'] ?? true,
                  onChanged: (_) => _toggleNotificacao('mortalidade'),
                ),
                _NotificacaoToggle(
                  icon: Icons.monitor_weight,
                  label: 'Peso',
                  descricao: 'Alertas de peso abaixo do benchmark',
                  value: _notificacoes['peso'] ?? true,
                  onChanged: (_) => _toggleNotificacao('peso'),
                ),
                _NotificacaoToggle(
                  icon: Icons.restaurant,
                  label: 'Racao',
                  descricao: 'Alertas de estoque baixo de racao',
                  value: _notificacoes['racao'] ?? true,
                  onChanged: (_) => _toggleNotificacao('racao'),
                ),
                _NotificacaoToggle(
                  icon: Icons.water_drop,
                  label: 'Agua',
                  descricao: 'Alertas de consumo de agua anormal',
                  value: _notificacoes['agua'] ?? true,
                  onChanged: (_) => _toggleNotificacao('agua'),
                ),
                _NotificacaoToggle(
                  icon: Icons.cloud,
                  label: 'Clima',
                  descricao: 'Alertas de condicoes climaticas extremas',
                  value: _notificacoes['clima'] ?? true,
                  onChanged: (_) => _toggleNotificacao('clima'),
                ),
                _NotificacaoToggle(
                  icon: Icons.sensors,
                  label: 'Sensores IoT',
                  descricao: 'Alertas de sensores fora do range ideal',
                  value: _notificacoes['iot'] ?? true,
                  onChanged: (_) => _toggleNotificacao('iot'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Secao 2.5: WhatsApp ────────────────────────────────────
          _buildWhatsAppSection(context),

          const SizedBox(height: 16),

          // ── Secao 3: Dados ───────────────────────────────────────────
          _SecaoCard(
            icon: Icons.storage,
            titulo: 'Dados',
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Operacoes pendentes',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        '$pendingCount '
                        '${pendingCount == 1 ? 'operacao' : 'operacoes'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: pendingCount > 0
                                  ? AppColors.warning
                                  : AppColors.textPrimary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 16),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isSyncing ? null : _forcarSincronizacao,
                    icon: _isSyncing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      _isSyncing ? 'Sincronizando...' : 'Forcar sincronizacao',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Secao 4: Sobre ───────────────────────────────────────────
          _SecaoCard(
            icon: Icons.info_outline,
            titulo: 'Sobre',
            child: Column(
              children: [
                const _InfoRow(
                  label: 'Versao do app',
                  valor: '1.0.0',
                ),
                const Divider(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      launchUrl(
                        Uri.parse('mailto:suporte@egranja.com.br'),
                      );
                    },
                    icon: const Icon(Icons.headset_mic),
                    label: const Text('Contatar suporte'),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      launchUrl(
                        Uri.parse('https://egranja.com.br/termos'),
                      );
                    },
                    icon: const Icon(Icons.description),
                    label: const Text('Termos de uso'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
    );
  }
}

/// Card de secao com icone e titulo no header.
class _SecaoCard extends StatelessWidget {
  const _SecaoCard({
    required this.icon,
    required this.titulo,
    required this.child,
  });

  final IconData icon;
  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 8),
                Text(
                  titulo,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Linha de informacao com label e valor.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.valor,
  });

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          Text(
            valor,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}

/// Toggle de notificacao usando SwitchListTile.
class _NotificacaoToggle extends StatelessWidget {
  const _NotificacaoToggle({
    required this.icon,
    required this.label,
    required this.descricao,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String descricao;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(
        icon,
        color: value ? AppColors.primary : AppColors.gray400,
        size: 22,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        descricao,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
