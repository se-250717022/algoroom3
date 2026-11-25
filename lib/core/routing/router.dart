import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/data/firebase_auth_repository.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/demo/presentation/demo_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../l10n/app_localizations.dart';
import '../settings/preferences.dart';
import '../widgets/status_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(preferencesProvider, (_, _) => refresh.value++);
  ref.listen(signedInProvider, (_, _) => refresh.value++);
  final router = GoRouter(
    refreshListenable: refresh,
    initialLocation: '/',
    redirect: (_, route) {
      final preferences = ref.read(preferencesProvider).value;
      final session = ref.read(signedInProvider);
      final location = route.matchedLocation;
      if (preferences?.onboarded == true && location == '/demo') return null;
      final target = preferences == null
          ? '/'
          : !preferences.onboarded
          ? '/onboarding'
          : session.isLoading
          ? '/'
          : session.value == true
          ? '/account'
          : '/login';
      return route.matchedLocation == target ? null : target;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const _SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: '/account',
        builder: (_, _) => const DemoScreen(authenticated: true),
      ),
      GoRoute(path: '/demo', builder: (_, _) => const DemoScreen()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _SplashScreen extends ConsumerWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final state = ref.watch(preferencesProvider);
    return Scaffold(
      body: SafeArea(
        child: StatusView(
          icon: Icons.house_rounded,
          title: state.hasError ? strings.loadError : strings.slogan,
          action: state.hasError
              ? FilledButton(
                  onPressed: () => ref.invalidate(preferencesProvider),
                  child: Text(strings.retry),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
