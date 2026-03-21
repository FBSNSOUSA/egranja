import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Status de uma solicitacao formal.
enum SolicitacaoStatus {
  /// Aguardando resposta.
  pendente,

  /// Ja respondida.
  respondida,

  /// Prazo expirado.
  expirada,
}

/// Card de solicitacao formal (contexto de chat/comunicacao).
///
/// Exibe informacoes da solicitacao com barra lateral colorida
/// baseada no status, prazo com contagem regressiva, e botoes
/// de acao contextuais.
///
/// Portado do componente React Native `SolicitacaoCard.tsx`.
class SolicitacaoCard extends StatelessWidget {
  const SolicitacaoCard({
    super.key,
    required this.titulo,
    required this.descricao,
    required this.prazo,
    this.status = SolicitacaoStatus.pendente,
    this.resposta,
    this.onResponder,
    this.onVerResposta,
    this.isProdutor = false,
  });

  /// Titulo da solicitacao.
  final String titulo;

  /// Descricao detalhada.
  final String descricao;

  /// Data limite para resposta.
  final DateTime prazo;

  /// Status atual da solicitacao.
  final SolicitacaoStatus status;

  /// Texto da resposta (quando respondida).
  final String? resposta;

  /// Callback para responder a solicitacao.
  final VoidCallback? onResponder;

  /// Callback para ver a resposta.
  final VoidCallback? onVerResposta;

  /// Se `true`, exibe botao de responder quando pendente.
  final bool isProdutor;

  Color get _statusColor {
    switch (status) {
      case SolicitacaoStatus.pendente:
        return AppColors.warning;
      case SolicitacaoStatus.respondida:
        return AppColors.success;
      case SolicitacaoStatus.expirada:
        return AppColors.danger;
    }
  }

  String get _statusLabel {
    switch (status) {
      case SolicitacaoStatus.pendente:
        return 'Pendente';
      case SolicitacaoStatus.respondida:
        return 'Respondida';
      case SolicitacaoStatus.expirada:
        return 'Expirada';
    }
  }

  String _formatTempoRestante() {
    final agora = DateTime.now();
    final diferenca = prazo.difference(agora);

    if (diferenca.isNegative) {
      return 'Prazo expirado';
    }

    if (diferenca.inDays > 0) {
      return '${diferenca.inDays} dia${diferenca.inDays != 1 ? 's' : ''} restante${diferenca.inDays != 1 ? 's' : ''}';
    }

    if (diferenca.inHours > 0) {
      return '${diferenca.inHours} hora${diferenca.inHours != 1 ? 's' : ''} restante${diferenca.inHours != 1 ? 's' : ''}';
    }

    return '${diferenca.inMinutes} minuto${diferenca.inMinutes != 1 ? 's' : ''} restante${diferenca.inMinutes != 1 ? 's' : ''}';
  }

  String _formatDate(DateTime date) {
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final ano = date.year;
    return '$dia/$mes/$ano';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Barra lateral colorida
            Container(
              width: 5,
              color: _statusColor,
            ),

            // Conteudo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: label + status chip
                    Row(
                      children: [
                        Text(
                          'Solicitacao',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(
                              color: _statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Titulo
                    Text(
                      titulo,
                      style: theme.textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Descricao
                    Text(
                      descricao,
                      style: theme.textTheme.bodySmall,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Prazo
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: status == SolicitacaoStatus.expirada
                              ? AppColors.danger
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Prazo: ${_formatDate(prazo)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: status == SolicitacaoStatus.expirada
                                ? AppColors.danger
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTempoRestante(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: status == SolicitacaoStatus.expirada
                                ? AppColors.danger
                                : AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Resposta (quando respondida)
                    if (status == SolicitacaoStatus.respondida &&
                        resposta != null) ...[
                      const Divider(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resposta:',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              resposta!,
                              style: theme.textTheme.bodySmall,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Botoes de acao
                    if (_showActions) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (status == SolicitacaoStatus.respondida &&
                              onVerResposta != null)
                            TextButton(
                              onPressed: onVerResposta,
                              child: const Text('Ver resposta'),
                            ),
                          if (status == SolicitacaoStatus.pendente &&
                              isProdutor &&
                              onResponder != null)
                            FilledButton(
                              onPressed: onResponder,
                              child: const Text('Responder'),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _showActions {
    if (status == SolicitacaoStatus.respondida && onVerResposta != null) {
      return true;
    }
    if (status == SolicitacaoStatus.pendente &&
        isProdutor &&
        onResponder != null) {
      return true;
    }
    return false;
  }
}
