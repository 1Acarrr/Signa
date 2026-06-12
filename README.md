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

### 3. Sunucu Kurulumu (Local Node.js Server)
Uygulamanın gerçek zamanlı iletişim özellikleri WebSocket sunucusu gerektirir.
```bash
cd server
npm install
npm start
```
Sunucu varsayılan olarak `localhost:37264` portunda çalışmaya başlayacaktır.
*(Not: Telefon üzerinden test ederken, telefonunuzun bilgisayarla aynı ağda olduğundan emin olun ve Flutter tarafındaki WebSocket IP adresini `127.0.0.1` yerine bilgisayarınızın yerel IP adresi örn: `192.168.1.X` olarak değiştirin).*

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
