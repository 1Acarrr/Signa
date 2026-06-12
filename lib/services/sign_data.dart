import 'package:flutter/material.dart';

class SignData {
  static final List<Map<String, dynamic>> categories = [
    {
      'id': 'harfler',
      'title': 'İşaret Dili Alfabesi',
      'color': const Color(0xFF6366F1),
      'image': 'assets/images/kategori/isaret-dili-alfabesi.png'
    },
    {
      'id': 'temel-iletisim',
      'title': 'Temel İletişim',
      'color': const Color(0xFF2563EB),
      'image': 'assets/images/kategori/temel-iletisim.png'
    },
    {
      'id': 'günlük-ihtiyaclar',
      'title': 'Günlük İhtiyaçlar',
      'color': const Color(0xFF10B981),
      'image': 'assets/images/kategori/gunluk-ihtiyaclar.png'
    },
    {
      'id': 'kisiler',
      'title': 'Kişiler',
      'color': const Color(0xFF7C3AED),
      'image': 'assets/images/kategori/kisiler.png'
    },
    {
      'id': 'mekanlar',
      'title': 'Mekânlar',
      'color': const Color(0xFFEC4899),
      'image': 'assets/images/kategori/mekanlar.png'
    },
    {
      'id': 'duygular',
      'title': 'Duygular',
      'color': const Color(0xFFFF9500),
      'image': 'assets/images/kategori/duygular.png'
    },
    {
      'id': 'fiiller',
      'title': 'Fiiller',
      'color': const Color(0xFF06B6D4),
      'image': 'assets/images/kategori/fiiller.png'
    },
  ];

  static final Map<String, List<String>> categorySigns = {
    'harfler': ['A', 'B', 'C', 'Ç', 'D', 'E', 'F', 'G', 'Ğ', 'H', 'I', 'İ', 'J', 'K', 'L', 'M', 'N', 'O', 'Ö', 'P', 'R', 'S', 'Ş', 'T', 'U', 'Ü', 'V', 'Y', 'Z'],
    'temel-iletisim': ['Merhaba', 'Selam', 'Günaydın', 'İyi Geceler', 'Nasılsın?', 'Teşekkür Etmek', 'Lütfen', 'Özür Dilemek', 'Rica Etmek', 'Yardım'],
    'günlük-ihtiyaclar': ['Su', 'Yemek', 'Ekmek', 'İlaç', 'Para', 'Şarj'],
    'kisiler': ['Anne', 'Baba', 'Kardeş', 'Bebek', 'Arkadaş', 'Öğretmen', 'Doktor', 'Polis', 'Çocuk', 'Öğrenci'],
    'mekanlar': ['Ev', 'Okul', 'Hastane', 'Eczane', 'Park', 'Market', 'Deniz'],
    'duygular': ['Mutlu', 'Heyecan', 'Korkmak', 'Kızmak', 'Nefret', 'Sevmek', 'Yorulmak', 'Üzülmek', 'Şaşırmak'],
    'fiiller': ['Anlamak', 'Bakmak', 'Bilmek', 'Duymak', 'Gelmek', 'Gitmek', 'Görmek', 'İstemek', 'Okumak', 'Yapmak'],
  };

  static final Map<String, String> _customFilenames = {
    'I': 'ı',
    'İ': 'i',
    'S': 'S',
    'İyi Geceler': 'iyi-geceler',
    'Teşekkür Etmek': 'teşekkür-etmek',
    'Özür Dilemek': 'özür-dilemek',
    'Rica Etmek': 'rica-etmek',
    'Nasılsın?': 'nasılsın',
    'Ekmek': 'ekmek-tohum-icin',
  };

  // Ek alan kelimeleri köklere dönüştüren dev sözlük
  static final Map<String, String> wordRoots = {
    // Mekanlar
    'okula': 'Okul', 'okulda': 'Okul', 'okuldan': 'Okul', 'okulu': 'Okul', 'okullar': 'Okul',
    'eve': 'Ev', 'evde': 'Ev', 'evden': 'Ev', 'evi': 'Ev', 'evler': 'Ev', 'evim': 'Ev', 'evime': 'Ev',
    'hastaneye': 'Hastane', 'hastanede': 'Hastane', 'hastaneden': 'Hastane', 'hastanesi': 'Hastane',
    'eczaneye': 'Eczane', 'eczanede': 'Eczane', 'eczaneden': 'Eczane', 'eczanesi': 'Eczane',
    'parka': 'Park', 'parkta': 'Park', 'parktan': 'Park', 'parkı': 'Park',
    'markete': 'Market', 'markette': 'Market', 'marketten': 'Market', 'marketi': 'Market',
    'denize': 'Deniz', 'denizde': 'Deniz', 'denizden': 'Deniz', 'denizi': 'Deniz',
    
    // Fiiller
    'anladım': 'Anlamak', 'anlıyorum': 'Anlamak', 'anlayacağım': 'Anlamak', 'anlar': 'Anlamak', 'anladı': 'Anlamak', 'anlamış': 'Anlamak', 'anlaşmak': 'Anlamak', 'anla': 'Anlamak',
    'baktım': 'Bakmak', 'bakıyorum': 'Bakmak', 'bakacağım': 'Bakmak', 'bakar': 'Bakmak', 'baktı': 'Bakmak', 'bakmış': 'Bakmak', 'baksana': 'Bakmak', 'bak': 'Bakmak',
    'bildim': 'Bilmek', 'biliyorum': 'Bilmek', 'bilecek': 'Bilmek', 'biliyor': 'Bilmek', 'bildi': 'Bilmek', 'bilmiş': 'Bilmek', 'bil': 'Bilmek',
    'duydum': 'Duymak', 'duyuyorum': 'Duymak', 'duyacağım': 'Duymak', 'duyar': 'Duymak', 'duydu': 'Duymak', 'duymuş': 'Duymak', 'duy': 'Duymak',
    'geldim': 'Gelmek', 'geliyorum': 'Gelmek', 'geleceğim': 'Gelmek', 'gelecek': 'Gelmek', 'gelir': 'Gelmek', 'geldi': 'Gelmek', 'gelmiş': 'Gelmek', 'gel': 'Gelmek',
    'gittim': 'Gitmek', 'gidiyorum': 'Gitmek', 'gideceğim': 'Gitmek', 'gidecek': 'Gitmek', 'gider': 'Gitmek', 'gitti': 'Gitmek', 'gitmiş': 'Gitmek', 'git': 'Gitmek', 'gidin': 'Gitmek',
    'gördüm': 'Görmek', 'görüyorum': 'Görmek', 'göreceğim': 'Görmek', 'görecek': 'Görmek', 'görür': 'Görmek', 'gördü': 'Görmek', 'görmüş': 'Görmek', 'gör': 'Görmek',
    'istedim': 'İstemek', 'istiyorum': 'İstemek', 'isteyeceğim': 'İstemek', 'isteyecek': 'İstemek', 'ister': 'İstemek', 'istedi': 'İstemek', 'istemiş': 'İstemek', 'iste': 'İstemek',
    'okudum': 'Okumak', 'okuyorum': 'Okumak', 'okuyacağım': 'Okumak', 'okuyacak': 'Okumak', 'okur': 'Okumak', 'okudu': 'Okumak', 'okumuş': 'Okumak', 'oku': 'Okumak',
    'yaptım': 'Yapmak', 'yapıyorum': 'Yapmak', 'yapacağım': 'Yapmak', 'yapacak': 'Yapmak', 'yapar': 'Yapmak', 'yaptı': 'Yapmak', 'yapmış': 'Yapmak', 'yap': 'Yapmak',

    // Duygular
    'mutluyum': 'Mutlu', 'mutluyuz': 'Mutlu', 'mutluydum': 'Mutlu', 'mutluluk': 'Mutlu',
    'heyecanlı': 'Heyecan', 'heyecanlıyım': 'Heyecan', 'heyecanlandım': 'Heyecan',
    'korktum': 'Korkmak', 'korkuyorum': 'Korkmak', 'korkacağım': 'Korkmak', 'korkar': 'Korkmak', 'korktu': 'Korkmak', 'kork': 'Korkmak',
    'kızdım': 'Kızmak', 'kızıyorum': 'Kızmak', 'kızacağım': 'Kızmak', 'kızar': 'Kızmak', 'kızdı': 'Kızmak', 'kız': 'Kızmak', 'kızgın': 'Kızmak',
    'nefretler': 'Nefret', 'nefretim': 'Nefret', 'nefreti': 'Nefret',
    'sevdim': 'Sevmek', 'seviyorum': 'Sevmek', 'seveceğim': 'Sevmek', 'sever': 'Sevmek', 'sevdi': 'Sevmek', 'sevmiş': 'Sevmek', 'sev': 'Sevmek',
    'yoruldum': 'Yorulmak', 'yoruluyorum': 'Yorulmak', 'yorulacağım': 'Yorulmak', 'yorulur': 'Yorulmak', 'yoruldu': 'Yorulmak', 'yorgunum': 'Yorulmak', 'yorgun': 'Yorulmak',
    'üzüldüm': 'Üzülmek', 'üzülüyorum': 'Üzülmek', 'üzüleceğim': 'Üzülmek', 'üzülür': 'Üzülmek', 'üzüldü': 'Üzülmek', 'üzgünüm': 'Üzülmek', 'üzgün': 'Üzülmek',
    'şaşırdım': 'Şaşırmak', 'şaşırıyorum': 'Şaşırmak', 'şaşıracağım': 'Şaşırmak', 'şaşırır': 'Şaşırmak', 'şaşırdı': 'Şaşırmak', 'şaşkınım': 'Şaşırmak', 'şaşkın': 'Şaşırmak',

    // Temel
    'merhabalar': 'Merhaba',
    'selamlar': 'Selam',
    'nasılsınız': 'Nasılsın?', 'nasılsın': 'Nasılsın?',
    'teşekkürler': 'Teşekkür Etmek', 'teşekkür': 'Teşekkür Etmek', 'teşekkür ederim': 'Teşekkür Etmek',
    'özür dilerim': 'Özür Dilemek', 'özür': 'Özür Dilemek',
    'rica ederim': 'Rica Etmek', 'rica': 'Rica Etmek',
    'yardımlar': 'Yardım', 'yardıma': 'Yardım', 'yardımı': 'Yardım',

    // İhtiyaçlar
    'suyu': 'Su', 'suya': 'Su', 'sular': 'Su',
    'yemeğe': 'Yemek', 'yemeği': 'Yemek', 'yemekte': 'Yemek', 'yemekten': 'Yemek', 'yemekler': 'Yemek', 'yemek': 'Yemek',
    'ekmeği': 'Ekmek', 'ekmeğe': 'Ekmek', 'ekmekte': 'Ekmek', 'ekmekler': 'Ekmek',
    'ilacı': 'İlaç', 'ilaca': 'İlaç', 'ilaçta': 'İlaç', 'ilaçlar': 'İlaç',
    'parayı': 'Para', 'paraya': 'Para', 'parası': 'Para', 'paralar': 'Para',
    'şarjı': 'Şarj', 'şarja': 'Şarj', 'şarjda': 'Şarj',

    // Kişiler
    'anneyi': 'Anne', 'anneye': 'Anne', 'annem': 'Anne', 'annemi': 'Anne', 'anneme': 'Anne', 'anneler': 'Anne',
    'babayı': 'Baba', 'babaya': 'Baba', 'babam': 'Baba', 'babamı': 'Baba', 'babama': 'Baba', 'babalar': 'Baba',
    'kardeşi': 'Kardeş', 'kardeşe': 'Kardeş', 'kardeşim': 'Kardeş', 'kardeşimi': 'Kardeş', 'kardeşime': 'Kardeş', 'kardeşler': 'Kardeş',
    'bebeği': 'Bebek', 'bebeğe': 'Bebek', 'bebekler': 'Bebek',
    'arkadaşı': 'Arkadaş', 'arkadaşa': 'Arkadaş', 'arkadaşım': 'Arkadaş', 'arkadaşımı': 'Arkadaş', 'arkadaşıma': 'Arkadaş', 'arkadaşlar': 'Arkadaş', 'arkadaşları': 'Arkadaş', 'arkadaşlara': 'Arkadaş',
    'öğretmeni': 'Öğretmen', 'öğretmene': 'Öğretmen', 'öğretmenim': 'Öğretmen', 'öğretmenimi': 'Öğretmen', 'öğretmenime': 'Öğretmen', 'öğretmenler': 'Öğretmen',
    'doktoru': 'Doktor', 'doktora': 'Doktor', 'doktorlar': 'Doktor',
    'polisi': 'Polis', 'polise': 'Polis', 'polisler': 'Polis',
    'çocuğu': 'Çocuk', 'çocuğa': 'Çocuk', 'çocuklar': 'Çocuk',
    'öğrenciyi': 'Öğrenci', 'öğrenciye': 'Öğrenci', 'öğrenciler': 'Öğrenci',
  };

  static String getFilename(String sign) {
    if (_customFilenames.containsKey(sign)) {
      return _customFilenames[sign]!;
    }
    
    // Default normalization
    return sign.toLowerCase()
        .replaceAll('?', '')
        .replaceAll('!', '')
        .trim();
  }

  static Map<String, String> getDailySign() {
    // Collect all signs into a flat list with their category IDs
    List<Map<String, String>> allSigns = [];
    categorySigns.forEach((categoryId, signs) {
      for (var sign in signs) {
        allSigns.add({'name': sign, 'categoryId': categoryId});
      }
    });

    if (allSigns.isEmpty) return {'name': 'Teşekkür Etmek', 'categoryId': 'temel-iletisim'};

    // Use current date as seed for random selection
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final index = seed % allSigns.length;
    
    return allSigns[index];
  }
}
