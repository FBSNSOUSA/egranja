import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// Widget raiz do eGranja.
///
/// Usa [MaterialApp.router] com GoRouter para navegacao declarativa
/// e aplica o tema Material 3 definido em [AppTheme].
class EGranjaApp extends StatelessWidget {
  const EGranjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final router = ref.watch(goRouterProvider);
        return MaterialApp.router(
          title: 'eGranja',
          theme: AppTheme.lightTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
