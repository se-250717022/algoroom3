# Firestore veri modeli taslağı

| Yol | Veri |
| --- | --- |
| users/{uid} | Özel profil, rıza sürümleri, doğrulama durumları ve hesap durumu |
| publicProfiles/{uid} | Görünen ad, yaş, yaklaşık bölge, amaç ve görünürlük |
| lifestyleProfiles/{uid} | Anket, kesin şartlar ve algoritma sürümü |
| listings/{listingId} | Sahip, yaklaşık bölge, fiyat, fotoğraf referansları ve moderasyon durumu |
| users/{uid}/favorites/{listingId} | İlan favorisi |
| likes/{senderId}/targets/{targetId} | Yönlü keşif beğenisi |
| matches/{pairId} | Sıralı katılımcı çiftine ait tek eşleşme |
| conversations/{pairId}/messages/{messageId} | Gönderen, tür, içerik, zaman ve idempotency kimliği |
| conversations/{pairId} | Katılımcılar, durum ve son mesaj özeti |
| users/{uid}/blocks/{targetId} | Engelleme kaydı |
| reports/{reportId} | Hedef, gerekçe ve moderasyon durumu |

Tam doğum tarihi, telefon ve e-posta özel profildedir. Zaman alanları Firestore Timestamp kullanır. Keşif indeksleri şehir, hesap durumu, amaç ve görünürlüğe göre, sohbet indeksleri katılımcı ve son mesaj zamanına göre tasarlanır. Bu şema henüz bir Firebase projesine uygulanmadı.
