import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:algoroom/app.dart';
import 'package:algoroom/core/settings/preferences.dart';
import 'package:algoroom/features/authentication/data/firebase_auth_repository.dart';
import 'package:algoroom/features/authentication/domain/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MemoryPreferences implements SharedPreferencesAsync {
  final _values = <String, Object>{};

  @override
  Future<bool?> getBool(String key) async => _values[key] as bool?;

  @override
  Future<String?> getString(String key) async => _values[key] as String?;

  @override
  Future<void> setBool(String key, bool value) async => _values[key] = value;

  @override
  Future<void> setString(String key, String value) async =>
      _values[key] = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAuth implements AuthRepository {
  final changes = StreamController<bool>();
  String? number;
  String? code;
  bool usedGoogle = false;

  @override
  Stream<bool> get signedIn async* {
    yield false;
    yield* changes.stream;
  }

  @override
  Future<PhoneChallenge> sendCode(String number) async {
    this.number = number;
    return (code) async {
      this.code = code;
      changes.add(true);
    };
  }

  @override
  Future<void> signInWithGoogle() async {
    usedGoogle = true;
    changes.add(true);
  }

  @override
  Future<void> signOut() async => changes.add(false);
}

void main() {
  for (final google in [false, true]) {
    testWidgets(
      google ? 'Signs in with Google' : 'Confirms the phone SMS code',
      (tester) async {
        final storage = _MemoryPreferences();
        await storage.setBool('onboarded', true);
        final auth = _TestAuth();
        addTearDown(() {
          unawaited(auth.changes.close());
        });
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageProvider.overrideWithValue(storage),
              authRepositoryProvider.overrideWith((ref) async => auth),
            ],
            child: const AlgoRoomApp(),
          ),
        );
        await tester.pumpAndSettle();
        if (google) {
          await tester.tap(find.text('Google ile devam et'));
          await tester.pumpAndSettle();
          expect(auth.usedGoogle, isTrue);
        } else {
          await tester.enterText(
            find.byKey(const ValueKey('phone')),
            '05321234567',
          );
          await tester.tap(find.text('SMS kodu gönder'));
          await tester.pumpAndSettle();
          expect(auth.number, '+905321234567');
          await tester.enterText(
            find.byKey(const ValueKey('sms-code')),
            '123456',
          );
          await tester.tap(find.text('Kodu doğrula'));
          await tester.pumpAndSettle();
          expect(auth.code, '123456');
        }
        await tester.tap(find.byTooltip('Çıkış yap'));
        await tester.pumpAndSettle();
        expect(find.text('Giriş yap'), findsOneWidget);
      },
    );
  }
  testWidgets('Completes onboarding, saves a room and restores preferences', (
    tester,
  ) async {
    final storage = _MemoryPreferences();
    Widget app() => ProviderScope(
      overrides: [localStorageProvider.overrideWithValue(storage)],
      child: const AlgoRoomApp(),
    );

    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Sana uygun oda arkadaşını bul.'), findsOneWidget);

    await tester.tap(find.text('İleri'));
    await tester.pumpAndSettle();
    expect(find.text('Yeni evini keşfet.'), findsOneWidget);

    await tester.tap(find.text('İleri'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Başla'));
    await tester.pumpAndSettle();
    expect(find.text('Giriş yap'), findsOneWidget);
    await tester.tap(find.text('Demoyu aç'));
    await tester.pumpAndSettle();
    expect(find.text('Demo'), findsOneWidget);

    await tester.tap(find.text('Odalar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Favoriye ekle').first);
    await tester.tap(find.text('Favoriler'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Favoriden çıkar'), findsOneWidget);

    await storage.setBool('english', true);
    await storage.setString('theme', 'dark');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Sign in'), findsOneWidget);
    await tester.tap(find.text('Open demo'));
    await tester.pumpAndSettle();
    expect(find.text('Discover'), findsOneWidget);
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}
