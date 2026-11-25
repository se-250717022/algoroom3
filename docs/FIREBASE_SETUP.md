# Firebase kurulumu

Üretim entegrasyonu geliştirme planındadır. Yerel demo Firebase yapılandırması gerektirmez.

1. Firebase Console'da geliştirme projesi oluştur. Platform projeleri oluşturulduktan sonra Android application ID ve iOS bundle ID ile uygulamaları kaydet.
2. Firebase CLI ve FlutterFire CLI kur. `firebase login`, `dart pub global activate flutterfire_cli` ve proje kökünde `flutterfire configure` komutlarını çalıştır. Üretilen yapılandırmayı geliştirme ortamına bağla.
3. Auth için e-posta/şifre ve gereken sağlayıcıları etkinleştir. Android debug ve yayın sertifikalarının SHA-1/SHA-256 değerlerini kaydet. Apple girişini ilgili Apple yetkileri ve Firebase yapılandırmasıyla etkinleştir.
4. Firestore ve Storage oluştur. Kuralları, indeksleri, TypeScript Functions ve App Check uygulamasını önce Emulator Suite üzerinde doğrula. Debug token'larını sadece geliştirme ortamında kullan.
5. FCM için iOS push yetkilerini ve APNs anahtarını ayarla. Android ve iOS bildirim izinlerini cihaz üzerinde doğrula.
6. Functions ve Storage gereksinimlerini Firebase fiyatlandırmasından kontrol et. Üretim dağıtımından önce faturalandırma ve ortam yetkilerini doğrula.

Resmî kaynaklar: [FlutterFire kurulumu](https://firebase.google.com/docs/flutter/setup), [Firebase fiyatlandırması](https://firebase.google.com/pricing), [Emulator Suite](https://firebase.google.com/docs/emulator-suite).
