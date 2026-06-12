# SIGNA - İşaret Dili Mobil Uygulaması

## Proje Açıklaması

SIGNA, işaret dili kullanan bireyler ile işaret dili bilmeyen bireyler arasındaki iletişimi kolaylaştırmak için geliştirilen Flutter tabanlı bir mobil uygulamadır.

Uygulama, telefon kamerası ile kullanıcının yaptığı el işaretlerini algılar, yapay zekâ modeliyle bu hareketleri sınıflandırır ve sonucu ekranda metin olarak gösterir. Ek olarak karşıdaki kişinin konuşmasını mikrofondan alarak yazıya çevirir. Böylece iki yönlü iletişim sağlanır. Bu iletişim esnasında parçalı kelimeleri **Gemini 3.5 Flash** kullanarak anlamlı ve kurallı cümlelere dönüştürür.

## Teknolojiler

### Mobil Uygulama
- **Flutter** - Cross-platform mobile framework
- **Dart** - Programming language

### Görüntü İşleme
- **Camera** - Flutter camera package
- **MediaPipe Hands** - Hand landmark detection
- **Google MLKit** - Hand pose detection

### Yapay Zekâ / Machine Learning
- **TensorFlow Lite** - Lightweight ML model (İşaret tanıma için)
- **Google Gemini 3.5 Flash** - Doğal dil işleme ve cümle kurma
- **Landmark-based Classification** - 21 hand landmark points

### Ses İşleme & Gerçek Zamanlı İletişim
- **speech_to_text** - Speech recognition
- **flutter_tts** - Text-to-speech
- **Node.js & WebSocket** - Gerçek zamanlı sunucu iletişimi

---

## 🚀 Başlangıç ve Kurulum

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları sırasıyla uygulayın.

### 1. Gereksinimler
- Flutter SDK >= 3.0.0
- Dart SDK
- Node.js (Sunucu için)
- Android Studio / Xcode

### 2. Projeyi Klonlayın
```bash
git clone https://github.com/1Acarrr/Signa.git
cd Signa
```

### 3. Yapay Zeka Sunucu Kurulumu (Python ML Server)
ÖNEMLİ NOT: Uygulamanın işaret dilini tanıyabilmesi için görüntüleri işleyen yapay zeka modeli (TFLite) bilgisayarınızda çalışan bir **Python WebSocket Sunucusu** üzerinden hizmet verir. Telefon, kameradan aldığı görüntüleri bu sunucuya gönderir ve sunucu işleyip sonucu geri döner.

Sunucuyu başlatmak için yeni bir komut istemi (CMD veya Terminal) açın ve model klasörüne gidin:

```bash
cd model_training
python server.py
```
Sunucu `localhost:8765` portunda çalışmaya başlayacaktır.

#### Telefonu Sunucuya Bağlama (ADB Reverse)
Eğer uygulamayı fiziksel bir Android telefonda (USB ile bağlı) test ediyorsanız, telefonun bilgisayardaki sunucuya (localhost) erişebilmesi için port yönlendirmesi yapmanız GEREKİR. Aksi halde "Connection refused" hatası alırsınız.
Aynı terminalde şu komutu çalıştırın:
```bash
adb reverse tcp:8765 tcp:8765
```

*(Not: Modelin çalışması için gereken `sign_model.tflite` ve `labels.txt` dosyaları `model_training/output/` klasörü içinde bulunur ve `server.py` tarafından otomatik olarak bu klasörden okunarak çalıştırılır.)*

### 4. Mobil Uygulama Kurulumu
Yeni bir terminal sekmesi açın ve proje kök dizinine (Signa) gelin:

```bash
# Bağımlılıkları yükleyin
flutter pub get
```

### 5. API Key Yapılandırması
Uygulamadaki cümle kurma işlemleri Google Gemini API kullanmaktadır.
`lib/screens/mutual_communication_screen.dart` dosyasını açın ve `_geminiApiKey` değişkenine kendi Gemini API anahtarınızı ekleyin:
```dart
static const String _geminiApiKey = 'BURAYA_KENDI_API_ANAHTARINIZI_YAZIN';
```

### 6. Uygulamayı Çalıştırma
```bash
# Bağlı cihazları listeleyin
flutter devices

# Uygulamayı başlatın
flutter run
```

---

## Modül Detayları ve Özellikler

1. **İşareti Çevir Modu:** Kameradan alınan görüntüyü TFLite ile işleyip metne çevirir.
2. **Konuşmayı Yazıya Çevir:** Sesli komutları dinleyip metne döker.
3. **Karşılıklı İletişim:** Gemini yapay zekası desteği ile kelimeleri anlamlı cümlelere dönüştürüp akıcı sohbet imkanı sunar.
4. **İşaretleri Öğren & Test Et:** Temel işaret dili eğitim seti içerir.

## Yapay Zekâ Modeli Hakkında
Model girişi: 21 el noktası × (x, y, z) = 63 değer
Model çıkışı: İşaret sınıfı tahmini. Model, TensorFlow kullanılarak eğitilmiş ve `.tflite` formatında mobil uyumlu hale getirilmiştir.

## Katkı Yapma
Bu proje eğitim ve sosyal etki amacıyla geliştirilmiştir. Katkılarınızı (Pull Request) memnuniyetle bekliyoruz!
