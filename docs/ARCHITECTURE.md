# Mimari

Özellikler lib/features altında toplanır. Domain modeli ve repository sözleşmesi Dart kullanır. Repository implementasyonlarını Riverpod sağlar. GoRouter açılış ve uygulama rotalarını yönetir. Tema ve ortak durum görünümleri core altında, TR/EN kaynakları lib/l10n altındadır.

Yerel demo repository kurgusal veriler kullanır. SharedPreferences yalnızca cihazdaki onboarding, tema ve dil tercihlerine ayrılır. Demo favorileri oturum süresince bellekte tutulur. Üretim repository ayrı giriş yapılandırmasına sahip olacaktır.

Firebase aşamasında doğrulanmış UID ve App Check sunucuda kontrol edilir. Eşleşme, engelleme, mesaj ve moderasyon işlemleri sunucuya taşınır. İstemci Firestore akışları ve sayfalı sorgular üzerinden erişim sağlar.
