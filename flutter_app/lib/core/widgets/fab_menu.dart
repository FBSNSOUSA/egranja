import 'package:flutter/material.dart';

/// Acao individual do [FABMenu].
class FABAction {
  const FABAction({
    required this.label,
    required this.icon,
    required this.onPress,
    this.color,
  });

  /// Rotulo exibido ao lado do mini-FAB.
  final String label;

  /// Icone do mini-FAB.
  final IconData icon;

  /// Callback ao pressionar.
  final VoidCallback onPress;

  /// Cor de fundo do mini-FAB. Quando nula, usa cor primaria.
  final Color? color;
}

/// FAB com menu expansivel de acoes.
///
/// Quando possui apenas uma acao, comporta-se como um FAB simples.
/// Com multiplas acoes, exibe um overlay com mini-FABs rotulados.
///
/// Portado do componente React Native `FABMenu.tsx`.
class FABMenu extends StatefulWidget {
  const FABMenu({
    super.key,
    required this.actions,
    this.mainIcon = Icons.add,
    this.backgroundColor,
  });

  /// Lista de acoes do menu.
  final List<FABAction> actions;

  /// Icone do FAB principal.
  final IconData mainIcon;

  /// Cor de fundo do FAB principal.
  final Color? backgroundColor;

  @override
  State<FABMenu> createState() => _FABMenuState();
}

class _FABMenuState extends State<FABMenu> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (widget.actions.length <= 1) {
      // Acao unica: executar direto
      if (widget.actions.isNotEmpty) {
        widget.actions.first.onPress();
      }
      return;
    }

    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    setState(() {
      _isOpen = false;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = widget.backgroundColor ?? theme.colorScheme.primary;

    // Acao unica: FAB simples
    if (widget.actions.length <= 1) {
      return FloatingActionButton(
        backgroundColor: bgColor,
        onPressed: _toggle,
        child: Icon(widget.mainIcon),
      );
    }

    return SizedBox(
      width: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Mini-FABs
          ...List.generate(widget.actions.length, (index) {
            final action = widget.actions[index];
            final reverseIndex = widget.actions.length - 1 - index;

            return FadeTransition(
              opacity: _expandAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, (reverseIndex + 1) * 0.3),
                  end: Offset.zero,
                ).animate(_expandAnimation),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Label
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(6),
                        color: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            action.label,
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Mini-FAB
                      FloatingActionButton.small(
                        heroTag: 'fab_action_$index',
                        backgroundColor:
                            action.color ?? theme.colorScheme.primary,
                        onPressed: () {
                          _close();
                          action.onPress();
                        },
                        child: Icon(action.icon),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),

          // Main FAB
          FloatingActionButton(
            backgroundColor: bgColor,
            onPressed: _toggle,
            child: AnimatedRotation(
              turns: _isOpen ? 0.125 : 0, // 45 graus
              duration: const Duration(milliseconds: 250),
              child: Icon(widget.mainIcon),
            ),
          ),
        ],
      ),
    );
  }
}
