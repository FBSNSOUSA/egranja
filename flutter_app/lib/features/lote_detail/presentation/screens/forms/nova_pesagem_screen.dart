import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/whatsapp_utils.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/core/database/app_database.dart';
import 'package:egranja_flutter/features/config/presentation/providers/whatsapp_config_provider.dart';
import '../../providers/pesagens_provider.dart';
import '../../providers/lote_detail_provider.dart';

/// Tela de nova pesagem com amostras dinamicas.
///
/// Suporta auto-save local (draft) e retomada de pesagem em andamento.
/// Permite adicionar multiplas amostras (quantidade + peso),
/// calcula peso medio por amostra e total.
class NovaPesagemScreen extends ConsumerStatefulWidget {
  const NovaPesagemScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovaPesagemScreen> createState() =>
      _NovaPesagemScreenState();
}

class _NovaPesagemScreenState extends ConsumerState<NovaPesagemScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<_AmostraData> _amostras = [_AmostraData()];
  DateTime _data = DateTime.now();

  // ── Draft / auto-save state ─────────────────────────────────────────
  int? _draftLocalId;
  bool _isDraft = false;
  bool _isSaved = false;
  Timer? _saveTimer;

  // ── Computed ────────────────────────────────────────────────────────
  double get _pesoMedioTotal {
    int totalQtd = 0;
    double totalPeso = 0;
    for (final amostra in _amostras) {
      final qtd = int.tryParse(amostra.quantidadeController.text) ?? 0;
      final peso = double.tryParse(amostra.pesoController.text) ?? 0;
      totalQtd += qtd;
      totalPeso += peso;
    }
    if (totalQtd == 0) return 0;
    return totalPeso / totalQtd;
  }

  /// Whether at least one sample has data worth saving.
  bool get _hasData {
    for (final a in _amostras) {
      final qtd = int.tryParse(a.quantidadeController.text) ?? 0;
      final peso = double.tryParse(a.pesoController.text) ?? 0;
      if (qtd > 0 || peso > 0) return true;
    }
    return false;
  }

  // ── Lifecycle ───────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    for (final amostra in _amostras) {
      amostra.dispose();
    }
    super.dispose();
  }

  // ── Draft load ──────────────────────────────────────────────────────

  Future<void> _loadDraft() async {
    final dao = ref.read(pesagensDaoProvider);
    final draft = await dao.getDraft(widget.loteId, DateTime.now());
    if (draft == null || !mounted) return;

    final items = await dao.getItemsByPesagemId(draft.id.toString());

    if (!mounted) return;

    setState(() {
      _draftLocalId = draft.id;
      _isDraft = true;
      _data = draft.data;

      // Replace default empty sample with draft items
      for (final a in _amostras) {
        a.dispose();
      }
      _amostras.clear();

      if (items.isEmpty) {
        _amostras.add(_AmostraData());
      } else {
        for (final item in items) {
          final amostra = _AmostraData();
          if (item.quantidade > 0) {
            amostra.quantidadeController.text = item.quantidade.toString();
          }
          if (item.peso > 0) {
            amostra.pesoController.text = item.peso.toString();
          }
          _amostras.add(amostra);
        }
      }
    });
  }

  // ── Auto-save ───────────────────────────────────────────────────────

  void _scheduleSave() {
    // Reset saved indicator
    if (_isSaved) {
      setState(() => _isSaved = false);
    }
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _saveToLocalDb);
  }

  Future<void> _saveToLocalDb() async {
    if (!_hasData || !mounted) return;

    final dao = ref.read(pesagensDaoProvider);
    final now = DateTime.now();
    final dateOnly = DateTime(_data.year, _data.month, _data.day);

    // Compute totals
    int totalQtd = 0;
    double totalPeso = 0;
    for (final a in _amostras) {
      final qtd = int.tryParse(a.quantidadeController.text) ?? 0;
      final peso = double.tryParse(a.pesoController.text) ?? 0;
      totalQtd += qtd;
      totalPeso += peso;
    }
    final pesoMedio = totalQtd > 0 ? totalPeso / totalQtd : 0.0;

    if (_draftLocalId != null) {
      // Update existing draft
      await dao.updateById(
        _draftLocalId!,
        PesagensCompanion(
          loteId: Value(widget.loteId),
          data: Value(dateOnly),
          quantidadeTotal: Value(totalQtd),
          pesoTotal: Value(totalPeso),
          pesoMedio: Value(pesoMedio),
          updatedAt: Value(now),
        ),
      );

      // Delete existing items and re-insert
      await dao.deleteItemsByPesagemId(_draftLocalId.toString());
    } else {
      // Insert new draft (serverId stays null = draft)
      final id = await dao.insertRow(
        PesagensCompanion.insert(
          loteId: widget.loteId,
          data: dateOnly,
          quantidadeTotal: totalQtd,
          pesoTotal: totalPeso,
          pesoMedio: pesoMedio,
          createdAt: now,
          updatedAt: now,
        ),
      );
      _draftLocalId = id;
    }

    // Insert all current items
    for (final a in _amostras) {
      final qtd = int.tryParse(a.quantidadeController.text) ?? 0;
      final peso = double.tryParse(a.pesoController.text) ?? 0;
      final itemPesoMedio = qtd > 0 ? peso / qtd : 0.0;

      await dao.insertItem(
        PesagemItemsCompanion.insert(
          pesagemId: _draftLocalId.toString(),
          quantidade: qtd,
          peso: peso,
          pesoMedio: itemPesoMedio,
          createdAt: now,
        ),
      );
    }

    if (mounted) {
      setState(() => _isSaved = true);
    }
  }

  // ── Actions ─────────────────────────────────────────────────────────

  void _addAmostra() {
    setState(() {
      _amostras.add(_AmostraData());
    });
    _scheduleSave();
  }

  void _removeAmostra(int index) {
    if (_amostras.length <= 1) return;
    setState(() {
      _amostras[index].dispose();
      _amostras.removeAt(index);
    });
    _scheduleSave();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dataFormatted =
        '${_data.year}-${_data.month.toString().padLeft(2, '0')}-${_data.day.toString().padLeft(2, '0')}';

    final items = _amostras.map((a) {
      return {
        'quantidade':
            int.tryParse(a.quantidadeController.text) ?? 0,
        'peso': double.tryParse(a.pesoController.text) ?? 0,
      };
    }).toList();

    final success = await ref
        .read(pesagensProvider(widget.loteId).notifier)
        .criar(data: dataFormatted, items: items);

    if (success && mounted) {
      // Delete local draft after successful API submission
      if (_draftLocalId != null) {
        final dao = ref.read(pesagensDaoProvider);
        await dao.deleteDraftWithItems(_draftLocalId!);
        _draftLocalId = null;
      }

      if (!mounted) return;

      // Invalidar cache de indicadores para recarregar
      ref
          .read(loteDetailProvider(widget.loteId).notifier)
          .invalidateCache();

      final message = ref.read(pesagensProvider(widget.loteId)).successMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message ?? 'Pesagem registrada com sucesso!'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      // Oferecer compartilhamento via WhatsApp
      final whatsappPhone = ref.read(whatsappConfigProvider).phone;
      if (whatsappPhone.isNotEmpty && mounted) {
        final loteDetail = ref.read(loteDetailProvider(widget.loteId));
        final galpaoNome = loteDetail.lote?.galpaoNome ?? 'Galpao';
        final dia = _data.day.toString().padLeft(2, '0');
        final mes = _data.month.toString().padLeft(2, '0');
        final ano = _data.year;
        final dataDisplay = '$dia/$mes/$ano';

        int totalAves = 0;
        double totalPeso = 0;
        for (final a in _amostras) {
          totalAves += int.tryParse(a.quantidadeController.text) ?? 0;
          totalPeso += double.tryParse(a.pesoController.text) ?? 0;
        }
        final pesoMedio = totalAves > 0 ? totalPeso / totalAves : 0.0;

        final shouldShare = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Compartilhar via WhatsApp?'),
            content: const Text(
              'Deseja enviar o resumo da pesagem para o integrador via WhatsApp?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Nao'),
              ),
              FilledButton.icon(
                onPressed: () => Navigator.pop(ctx, true),
                icon: const Icon(Icons.chat, size: 18),
                label: const Text('Compartilhar'),
              ),
            ],
          ),
        );

        if (shouldShare == true && mounted) {
          final whatsappMessage = WhatsAppUtils.formatarPesagem(
            galpaoNome: galpaoNome,
            data: dataDisplay,
            numAmostras: _amostras.length,
            pesoMedio: pesoMedio,
            totalAves: totalAves,
          );

          final sent = await WhatsAppUtils.compartilhar(
            phone: whatsappPhone,
            message: whatsappMessage,
          );

          if (!sent && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nao foi possivel abrir o WhatsApp.'),
                backgroundColor: AppColors.warning,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }

      if (mounted) context.pop();
    } else if (mounted) {
      final error = ref.read(pesagensProvider(widget.loteId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(error ?? 'Erro ao salvar pesagem.'),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Tentar novamente',
            textColor: AppColors.white,
            onPressed: _submit,
          ),
        ),
      );
    }
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pesagensProvider(widget.loteId));
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Auto-save indicator
          if (_isSaved || _isDraft)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  if (_isDraft) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Rascunho',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (_isSaved)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_done_outlined, size: 18, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Salvo',
                          style: TextStyle(fontSize: 12, color: AppColors.success),
                        ),
                      ],
                    ),
                ],
              ),
            ),

          // Data
          DatePickerField(
            label: 'Data',
            value: _data,
            required: true,
            maximumDate: DateTime.now(),
            onChange: (date) {
              setState(() => _data = date);
              _scheduleSave();
            },
          ),
          const SizedBox(height: 16),

          // Status do rascunho
          if (_isDraft)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withAlpha(80)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pesagem em andamento - ${_amostras.length} amostra${_amostras.length != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_isDraft) const SizedBox(height: 16),

          // Amostras
          for (int index = 0; index < _amostras.length; index++)
            _AmostraWidget(
              key: ValueKey('amostra_${_amostras[index].hashCode}'),
              index: index,
              amostra: _amostras[index],
              canRemove: _amostras.length > 1,
              onRemove: () => _removeAmostra(index),
              onChanged: () {
                setState(() {});
                _scheduleSave();
              },
            ),

          const SizedBox(height: 8),

          // Adicionar amostra
          OutlinedButton.icon(
            onPressed: _addAmostra,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Amostra'),
          ),
          const SizedBox(height: 24),

          // Peso medio total
          Card(
            color: theme.colorScheme.primaryContainer.withAlpha(40),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Peso Medio Total',
                    style: theme.textTheme.titleSmall,
                  ),
                  Text(
                    '${_pesoMedioTotal.toStringAsFixed(0)} g',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Botao finalizar - grande para uso no campo
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: state.isSaving ? null : _submit,
              icon: state.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                state.isSaving
                    ? 'Enviando...'
                    : 'Finalizar e Enviar Pesagem',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmostraData {
  final TextEditingController quantidadeController =
      TextEditingController();
  final TextEditingController pesoController = TextEditingController();

  double get pesoMedio {
    final qtd =
        int.tryParse(quantidadeController.text) ?? 0;
    final peso = double.tryParse(pesoController.text) ?? 0;
    if (qtd == 0) return 0;
    return peso / qtd;
  }

  void dispose() {
    quantidadeController.dispose();
    pesoController.dispose();
  }
}

class _AmostraWidget extends StatelessWidget {
  const _AmostraWidget({
    super.key,
    required this.index,
    required this.amostra,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final _AmostraData amostra;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com botao de remover
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amostra ${index + 1}',
                  style: theme.textTheme.titleSmall,
                ),
                if (canRemove)
                  SizedBox(
                    height: 36,
                    child: TextButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Remover'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Campos
            Row(
              children: [
                Expanded(
                  child: FormFieldWidget(
                    label: 'Quantidade',
                    placeholder: 'Aves',
                    keyboardType: TextInputType.number,
                    controller: amostra.quantidadeController,
                    required: true,
                    onChanged: (_) => onChanged(),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Obrigatorio';
                      }
                      if (int.tryParse(v) == null || int.parse(v) <= 0) {
                        return 'Invalido';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FormFieldWidget(
                    label: 'Peso Total',
                    placeholder: 'Gramas',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    suffix: 'g',
                    controller: amostra.pesoController,
                    required: true,
                    onChanged: (_) => onChanged(),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Obrigatorio';
                      }
                      if (double.tryParse(v) == null ||
                          double.parse(v) <= 0) {
                        return 'Invalido';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Peso medio da amostra
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Medio: ${amostra.pesoMedio.toStringAsFixed(0)} g',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
