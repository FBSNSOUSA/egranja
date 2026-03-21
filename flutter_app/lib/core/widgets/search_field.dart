import 'dart:async';

import 'package:flutter/material.dart';

/// Campo de busca com debounce e botao de limpar.
///
/// Implementa um campo de texto estilo Material 3 SearchBar
/// com icone de busca, botao de limpar (quando tem texto),
/// e debounce de 300ms no callback [onChanged].
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.query = '',
    this.onChanged,
    this.onClear,
    this.placeholder = 'Buscar...',
    this.autofocus = false,
  });

  /// Valor inicial da busca.
  final String query;

  /// Callback com debounce de 300ms ao alterar o texto.
  final ValueChanged<String>? onChanged;

  /// Callback ao limpar o campo.
  final VoidCallback? onClear;

  /// Texto placeholder.
  final String placeholder;

  /// Se `true`, foca automaticamente ao montar.
  final bool autofocus;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant SearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != oldWidget.query &&
        widget.query != _controller.text) {
      _controller.text = widget.query;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Atualiza UI imediatamente para mostrar/ocultar botao de limpar
    setState(() {});

    // Debounce no callback externo
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged?.call(_controller.text);
    });
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _controller.text.isNotEmpty;

    return Semantics(
      label: 'Campo de busca',
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasText
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Limpar busca',
                  onPressed: _clear,
                )
              : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
