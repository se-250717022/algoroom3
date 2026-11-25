# AlgoRoom

Oda arkadaşı ve oda keşfi için Türkçe ve İngilizce Flutter projesi. Yerel demo, kurgusal profiller ve oda ilanlarıyla çalışır. Çalışma kapsamı ve doğrulama sonuçları PROJECT_STATUS.md dosyasındadır.

## Geliştirme ortamı

[Flutter kararlı SDK](https://docs.flutter.dev/install), Git ve Android için [Android araç zinciri](https://docs.flutter.dev/platform-integration/android/setup) gerekir. Doğrulanan sürümler Flutter 3.50.1 ve Dart 3.14.0. iOS derlemesi macOS ve Xcode gerektirir.

```sh
flutter --version
dart --version
flutter doctor -v
flutter pub get
flutter analyze
flutter test
flutter run
```

İlk açılışta üç sayfalı tanıtım gösterilir. Ardından giriş ekranı açılır. Demoyu aç seçeneğiyle hesap kullanmadan devam edebilirsin. Telefon ve Google girişi için [Firebase Auth kurulumuna](docs/FIREBASE_AUTH.md) bak. Tema, dil ve onboarding tercihi cihaza kaydedilir. İlan favorileri uygulama oturumunda tutulur. Firebase kurulumu için docs/FIREBASE_SETUP.md dosyasına bak.

Android debug derlemesi için `flutter build apk --debug` kullan. Yayın derlemesi için kendi imza anahtarını ve gizli Gradle ayarlarını yapılandır. Anahtar ve şifreleri sürüm kontrolü dışında tut.
