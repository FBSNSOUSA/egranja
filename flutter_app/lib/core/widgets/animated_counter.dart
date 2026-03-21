import 'package:flutter/material.dart';

/// A widget that smoothly animates between numeric values.
///
/// When [value] changes, the displayed number transitions from the old value
/// to the new one over [duration], using a [TweenAnimationBuilder].
///
/// A [formatter] function can be provided to customize how the number is
/// displayed (e.g., adding units like "g" or "%" or formatting decimals).
///
/// Example usage:
/// ```dart
/// AnimatedCounter(
///   value: 1680,
///   textStyle: theme.textTheme.headlineSmall,
///   formatter: (v) => '${v.toStringAsFixed(0)} g',
/// )
/// ```
class AnimatedCounter extends StatelessWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
    this.textStyle,
    this.formatter,
    this.textAlign,
  });

  /// The target numeric value to animate towards.
  final double value;

  /// Duration of the count animation. Defaults to 600ms.
  final Duration duration;

  /// Animation curve. Defaults to [Curves.easeInOut].
  final Curve curve;

  /// Text style for the displayed value.
  final TextStyle? textStyle;

  /// Optional formatter to customize how the value is displayed.
  /// If null, displays the value with no decimal places.
  final String Function(double value)? formatter;

  /// Text alignment.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedValue, child) {
        final displayText = formatter != null
            ? formatter!(animatedValue)
            : animatedValue.toStringAsFixed(0);

        return Text(
          displayText,
          style: textStyle,
          textAlign: textAlign,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
