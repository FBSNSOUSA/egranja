import 'package:flutter/material.dart';

/// A list view that animates its children with staggered fade + slide-up
/// transitions when first built.
///
/// Each child fades in and slides up from a slight offset, with a configurable
/// delay between items to create a cascading appearance effect.
///
/// Example usage:
/// ```dart
/// StaggeredListView(
///   children: items.map((item) => ItemCard(item: item)).toList(),
/// )
/// ```
class StaggeredListView extends StatefulWidget {
  const StaggeredListView({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 300),
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  /// The widgets to display with staggered animation.
  final List<Widget> children;

  /// Delay between each item's animation start. Defaults to 50ms.
  final Duration staggerDelay;

  /// Duration of each individual item's animation. Defaults to 300ms.
  final Duration itemDuration;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Scroll physics for the list.
  final ScrollPhysics? physics;

  /// Whether the list should shrink-wrap its content.
  final bool shrinkWrap;

  @override
  State<StaggeredListView> createState() => _StaggeredListViewState();
}

class _StaggeredListViewState extends State<StaggeredListView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Total duration = last item start + item duration
    final totalMs = widget.children.isEmpty
        ? 0
        : (widget.children.length - 1) * widget.staggerDelay.inMilliseconds +
            widget.itemDuration.inMilliseconds;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(StaggeredListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Restart animation if children count changed
    if (oldWidget.children.length != widget.children.length) {
      final totalMs = widget.children.isEmpty
          ? 0
          : (widget.children.length - 1) *
                  widget.staggerDelay.inMilliseconds +
              widget.itemDuration.inMilliseconds;

      _controller.duration = Duration(milliseconds: totalMs);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalMs = _controller.duration?.inMilliseconds ?? 1;

    return ListView.builder(
      padding: widget.padding,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        final startMs = index * widget.staggerDelay.inMilliseconds;
        final endMs = startMs + widget.itemDuration.inMilliseconds;

        final interval = Interval(
          startMs / totalMs,
          (endMs / totalMs).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        );

        final animation = CurvedAnimation(
          parent: _controller,
          curve: interval,
        );

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.15),
              end: Offset.zero,
            ).animate(animation),
            child: widget.children[index],
          ),
        );
      },
    );
  }
}
