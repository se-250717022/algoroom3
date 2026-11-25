import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  const Preferences({
    required this.onboarded,
    required this.english,
    required this.theme,
    this.saving = false,
    this.saveFailed = false,
  });

  final bool onboarded;
  final bool english;
  final ThemeMode theme;
  final bool saving;
  final bool saveFailed;

  Preferences copyWith({
    bool? onboarded,
    bool? english,
    ThemeMode? theme,
    bool saving = false,
    bool saveFailed = false,
  }) => Preferences(
    onboarded: onboarded ?? this.onboarded,
    english: english ?? this.english,
    theme: theme ?? this.theme,
    saving: saving,
    saveFailed: saveFailed,
  );
}

final localStorageProvider = Provider((ref) => SharedPreferencesAsync());

final preferencesProvider =
    AsyncNotifierProvider<PreferencesController, Preferences>(
      PreferencesController.new,
    );

class PreferencesController extends AsyncNotifier<Preferences> {
  @override
  Future<Preferences> build() async {
    final store = ref.watch(localStorageProvider);
    final onboarded = await store.getBool('onboarded') ?? false;
    final english = await store.getBool('english') ?? false;
    final theme = switch (await store.getString('theme')) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return Preferences(onboarded: onboarded, english: english, theme: theme);
  }

  Future<void> finishOnboarding() => _save(
    (store) => store.setBool('onboarded', true),
    (previous) => previous.copyWith(onboarded: true),
  );

  Future<void> setLanguage(bool english) => _save(
    (store) => store.setBool('english', english),
    (previous) => previous.copyWith(english: english),
  );

  Future<void> setTheme(ThemeMode theme) => _save(
    (store) => store.setString('theme', theme.name),
    (previous) => previous.copyWith(theme: theme),
  );

  Future<void> _save(
    Future<void> Function(SharedPreferencesAsync) write,
    Preferences Function(Preferences) update,
  ) async {
    final previous = state.value;
    if (previous == null || previous.saving) return;

    state = AsyncData(previous.copyWith(saving: true));
    try {
      await write(ref.read(localStorageProvider));
      if (ref.mounted) state = AsyncData(update(previous));
    } catch (_) {
      if (ref.mounted) state = AsyncData(previous.copyWith(saveFailed: true));
    }
  }
}
