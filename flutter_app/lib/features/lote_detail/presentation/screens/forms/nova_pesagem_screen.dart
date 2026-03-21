import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import '../../providers/pesagens_provider.dart';
import '../../providers/lote_detail_provider.dart';

/// Tela de nova pesagem com amostras dinamicas.
///
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

  double get _pesoMedioTotal {
    int totalQtd = 0;
    double totalPeso = 0;
    for (final amostra in _amostras) {
      final qtd = int.tryParse(amostra.quantidadeController.text) ?? 0;
      final peso =
          double.tryParse(amostra.pesoController.text) ?? 0;
      totalQtd += qtd;
      totalPeso += peso;
    }
    if (totalQtd == 0) return 0;
    return totalPeso / totalQtd;
  }

  void _addAmostra() {
    setState(() {
      _amostras.add(_AmostraData());
    });
  }

  void _removeAmostra(int index) {
    if (_amostras.length <= 1) return;
    setState(() {
      _amostras[index].dispose();
      _amostras.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final itens = _amostras.map((a) {
      return {
        'quantidade':
            int.tryParse(a.quantidadeController.text) ?? 0,
        'peso': double.tryParse(a.pesoController.text) ?? 0,
      };
    }).toList();

    final success = await ref
        .read(pesagensProvider(widget.loteId).notifier)
        .criar(itens: itens);

    if (success && mounted) {
      // Invalidar cache de indicadores para recarregar
      ref
          .read(loteDetailProvider(widget.loteId).notifier)
          .invalidateCache();

      final message = ref.read(pesagensProvider(widget.loteId)).successMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      context.pop();
    } else if (mounted) {
      final error = ref.read(pesagensProvider(widget.loteId)).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (final amostra in _amostras) {
      amostra.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pesagensProvider(widget.loteId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Pesagem'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amostras
            ...List.generate(_amostras.length, (index) {
              return _AmostraWidget(
                index: index,
                amostra: _amostras[index],
                canRemove: _amostras.length > 1,
                onRemove: () => _removeAmostra(index),
                onChanged: () => setState(() {}),
              );
            }),

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

            // Botao finalizar
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.isSaving ? null : _submit,
                child: state.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Finalizar Pesagem'),
              ),
            ),
          ],
        ),
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amostra ${index + 1}',
                  style: theme.textTheme.titleSmall,
                ),
                if (canRemove)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onRemove,
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
