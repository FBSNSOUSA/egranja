import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Efeito shimmer animado para placeholders de carregamento.
///
/// Cria um gradiente animado que varre da esquerda para a direita,
/// simulando o carregamento de conteudo (skeleton screen pattern).
class ShimmerEffect extends StatefulWidget {
  const ShimmerEffect({
    super.key,
    required this.child,
  });

  /// Widget filho que recebera o efeito shimmer.
  final Widget child;

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.gray200,
                AppColors.gray100,
                AppColors.gray200,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Bloco retangular base para composicao de skeletons.
class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.borderRadius = 6,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Skeleton placeholder que imita o formato do [IndicatorCard].
class SkeletonIndicator extends StatelessWidget {
  const SkeletonIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _SkeletonBlock(width: 28, height: 28, borderRadius: 14),
              SizedBox(height: 8),
              _SkeletonBlock(width: 60, height: 14),
              SizedBox(height: 4),
              _SkeletonBlock(width: 48, height: 20),
              SizedBox(height: 4),
              _SkeletonBlock(width: 72, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Skeleton placeholder que imita o formato do [LoteCard].
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _SkeletonBlock(width: 120, height: 16),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            _SkeletonBlock(width: 60, height: 24, borderRadius: 12),
                            SizedBox(width: 6),
                            _SkeletonBlock(width: 80, height: 24, borderRadius: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Column(
                    children: [
                      _SkeletonBlock(width: 40, height: 28),
                      SizedBox(height: 2),
                      _SkeletonBlock(width: 28, height: 12),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const _SkeletonBlock(width: 140, height: 12),
              const SizedBox(height: 12),
              // Divider
              const _SkeletonBlock(width: double.infinity, height: 1),
              const SizedBox(height: 12),
              // Indicators row
              const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBlock(width: 60, height: 12),
                        SizedBox(height: 4),
                        _SkeletonBlock(width: 80, height: 16),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBlock(width: 70, height: 12),
                        SizedBox(height: 4),
                        _SkeletonBlock(width: 90, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lista de [SkeletonCard] para uso como placeholder de listas.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 3,
  });

  /// Quantidade de cards skeleton a exibir.
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (_) => const SkeletonCard(),
      ),
    );
  }
}
