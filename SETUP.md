# SIGNA - Kurulum ve Geliştirme Kılavuzu

## İçindekiler
- [Sistem Gereksinimleri](#sistem-gereksinimleri)
- [Kurulum](#kurulum)
- [Proje Yapısı](#proje-yapısı)
- [Geliştirme](#geliştirme)
- [Building](#building)
- [Sorun Giderme](#sorun-giderme)

## Sistem Gereksinimleri

### Minimum Gereksinimler
- **OS**: Windows 10/11, macOS 10.14+, Linux (Ubuntu 18.04+)
- **RAM**: 8GB
- **Disk**: 15GB
- **Flutter SDK**: >= 3.0.0 
- **Dart SDK**: >= 3.0.0

### Geliştirme Araçları
- **IDE**: Android Studio, VS Code veya IntelliJ IDEA
- **Android SDK**: API Level 21+
- **Xcode**: 14.0+ (macOS geliştirmesi için)

## Kurulum

### 1. Flutter SDK Kurulumu

#### Windows
```bash
# Flutter'ı indir
https://flutter.dev/docs/get-started/install/windows

# PATH'e Flutter ekle (Sistem Değişkenleri)
C:\flutter\bin
```

#### macOS
```bash
# Homebrew kullanarak
brew install flutter

# Veya manuel kurulum
# https://flutter.dev/docs/get-started/install/macos
```

#### Linux (Ubuntu)
```bash
sudo apt-get install flutter
```

### 2. Flutter Kurulumunu Doğrula
```bash
flutter doctor
```

Çıktı:
```
✓ Flutter (Channel stable, 3.x.x, ...)
✓ Android toolchain
✓ Xcode (macOS için)
✓ VS Code
✓ Connected device
```

### 3. SIGNA Projesini Klonla

```bash
git clone <repository-url>
cd MobilProgramlama
```

### 4. Bağımlılıkları Yükle

```bash
flutter pub get
```

### 5. Emülatör Kurulumu

#### Android Emülatörü
```bash
# Mevcut emülatörleri listele
flutter emulators

# Emülatör başlat
flutter emulators --launch <emulator-id>

# Veya Android Studio'dan başlat
```

#### iOS Simulator (macOS)
```bash
# Simulator başlat
open -a Simulator

# Veya
xcrun simctl list devices
xcrun simctl boot <device-id>
```

## Proje Yapısı

```
SIGNA/
├── lib/
│   ├── main.dart                 # Giriş noktası
│   ├── config/                   # Konfigürasyon
│   ├── screens/                  # Tüm ekranlar
│   ├── models/                   # Veri modelleri
│   ├── providers/                # State management
│   ├── services/                 # İş mantığı servisleri
│   ├── utils/                    # Yardımcı fonksiyonlar
│   └── widgets/                  # Özel widget'lar
├── assets/                       # Resimler, fontlar, vb.
├── android/                      # Android spesifik dosyalar
├── ios/                          # iOS spesifik dosyalar
├── pubspec.yaml                  # Proje yapılandırması
└── README.md                     # Proje açıklaması
```

## Geliştirme

### Projeyi Çalıştır
```bash
flutter run
```

### Debug Modunda Çalıştır
```bash
flutter run -v
```

### Release Modunda Çalıştır
```bash
flutter run --release
```

### Belirli Cihazda Çalıştır
```bash
flutter devices
flutter run -d <device-id>
```

### Hot Reload
Kod yazarken değişiklikleri anında yüklemek için:
- Terminal: `r` tuşuna basın
- VS Code: Dosyayı kaydedin (otomatik)
- Android Studio: ⚡ hot reload butonuna tıklayın

## Firebase Kurulumu (Opsiyonel)

### 1. Firebase Projesi Oluştur
```
https://firebase.google.com/
```

### 2. Android için Firebase Yapılandırması
```bash
# FlutterFire CLI'yi kur
dart pub global activate flutterfire_cli

# Firebase yapılandırmasını oluştur
flutterfire configure
```

### 3. iOS için Firebase Yapılandırması
```bash
# Podfile güncellenir
cd ios
pod install
```

## Building

### Android APK Oluştur
```bash
flutter build apk --release
```

Çıkış: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS IPA Oluştur (macOS'ta)
```bash
flutter build ios --release
```

## Kod Kalitesi

### Lint Kontrol
```bash
flutter analyze
```

### Kod Formatting
```bash
dart format lib/
```

### Test Çalıştır
```bash
flutter test
```

## Sorun Giderme

### Problem: "flutter command not found"
**Çözüm:** PATH'e Flutter bin klasörünü ekle

### Problem: "No devices found"
**Çözüm:** 
```bash
flutter devices
flutter emulators --launch <name>
```

### Problem: Gradle build hatası
**Çözüm:**
```bash
flutter clean
flutter pub get
flutter run
```

### Problem: Pod install hatası
**Çözüm:**
```bash
cd ios
rm Podfile.lock
pod install --repo-update
cd ..
flutter run
```

### Problem: Screenshot alırken hata
**Çözüm:**
```bash
flutter run -v
# Veya emülatör önce başlat
```

## Faydalı Komutlar

```bash
# Tüm bağımlılıkları güncelle
flutter pub upgrade

# Pub cache'i temizle
flutter clean

# Proje dosyalarını oluştur (build_runner için)
flutter pub run build_runner build

# Watch mode'de dosyaları izle
flutter pub run build_runner watch

# Devamlı analiz
flutter analyze --watch
```

## Hata Raporlama

Bir sorunla karşılaşırsanız:
1. `flutter doctor` çalıştırın
2. Hata mesajını tam olarak kopyalayın
3. Issue oluşturun: [GitHub Issues]

## İletişim

- **E-posta**: isa@example.com
- **GitHub**: [Repository]

---

**Son Güncelleme:** 2026
**Versiyon:** 1.0.0
