import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Builds a [CustomTransitionPage] with a combined fade + slight slide-from-right
/// transition. Used by [GoRouter] routes for smooth navigation.
///
/// The slide offset starts at 0.1 (10% from the right) and fades in
/// simultaneously over 300ms with an [Curves.easeInOut] curve.
CustomTransitionPage<void> buildFadeSlideTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
