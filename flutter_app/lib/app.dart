import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        // Usa ref.read para obter a instancia estavel do GoRouter.
        // O router nao e recriado a cada mudanca de auth — em vez disso,
        // usa refreshListenable para re-avaliar apenas o redirect.
        final router = ref.read(goRouterProvider);
        return MaterialApp.router(
          title: 'eGranja',
          theme: AppTheme.lightTheme,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          locale: const Locale('pt', 'BR'),
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
