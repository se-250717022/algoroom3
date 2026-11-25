import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/router.dart';
import 'core/settings/preferences.dart';
import 'core/theme/algoroom_theme.dart';
import 'l10n/app_localizations.dart';

class AlgoRoomApp extends ConsumerWidget {
  const AlgoRoomApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(preferencesProvider).value;
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.brand,
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings?.english == true
          ? const Locale('en')
          : const Locale('tr'),
      theme: algoRoomTheme(Brightness.light),
      darkTheme: algoRoomTheme(Brightness.dark),
      themeMode: settings?.theme ?? ThemeMode.system,
    );
  }
}
