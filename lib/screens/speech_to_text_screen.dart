import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:gif/gif.dart';
import '../services/sign_data.dart';
import 'dart:ui';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({Key? key}) : super(key: key);

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  
  // Kuyruk Sistemi Değişkenleri
  final List<Map<String, dynamic>> _gifQueue = [];
  final List<Map<String, dynamic>> _historyQueue = [];
  bool _isPlayingGif = false;
  int _processedWordCount = 0;
  int _playbackId = 0;
  
  String? _currentGifPath;
  String? _currentSignName;
  bool _currentIsLetter = false;

  late AnimationController _waveController;
  late GifController _gifController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _gifController = GifController(vsync: this);
    
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        setState(() => _isListening = false);
        debugPrint('Speech error: $errorNotification');
      },
    );
    if (!mounted) return;
    if (available) {
      debugPrint('Speech to text initialized.');
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() {
          _isListening = true;
          // Yeni dinleme başladığında sayaçları sıfırlayalım ki temiz başlasın
          _processedWordCount = 0;
          _recognizedText = '';
          _historyQueue.clear(); // Her yeni bas-konuşta geçmişi temizle
          _gifQueue.clear();
          _playbackId++; // Eski oynatmayı anında kes
          _isPlayingGif = false;
        });
        
        _speech.listen(
          onResult: (val) {
            setState(() {
              _recognizedText = val.recognizedWords;
            });
            _extractNewWords(val.recognizedWords);
          },
          localeId: 'tr_TR',
          partialResults: true,
          listenMode: stt.ListenMode.dictation,
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _extractNewWords(String text) {
    if (text.isEmpty) return;

    final currentWords = text.trim().split(RegExp(r'\s+'));
    
    if (currentWords.length > _processedWordCount) {
      // Yeni kelimeler eklenmiş
      final newWords = currentWords.sublist(_processedWordCount);
      _processedWordCount = currentWords.length;
      
      for (String w in newWords) {
        _queueWord(w);
      }
    } else if (currentWords.length < _processedWordCount) {
      // Konuşma motoru sıfırlanmış veya metin baştan başlamış
      _processedWordCount = currentWords.length;
      _gifQueue.clear(); // Kuyruğu temizle ki eski metinler oynamasın
      _playbackId++; // Mevcut oynatmayı kes
      _isPlayingGif = false;
      for (String w in currentWords) {
        _queueWord(w);
      }
    }
  }

  String _trToLower(String text) {
    return text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
  }

  String _trToUpper(String text) {
    return text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
  }

  void _queueWord(String word) {
    // Türkçe karakterleri güvenli bir şekilde küçük harfe çevirelim
    final safeLower = _trToLower(word);
    final cleanWord = safeLower.replaceAll(RegExp(r'[^\w\sğüşöçıi]'), '').trim();
    if (cleanWord.isEmpty) return;

    String? foundSignName;
    String? foundCategoryId;
    
    // 1. Morfolojik Analiz: Kelime ek almış mı? Kök sözlüğünde varsa köküne çevir
    String searchWord = cleanWord;
    if (SignData.wordRoots.containsKey(cleanWord)) {
      searchWord = _trToLower(SignData.wordRoots[cleanWord]!);
    }
    
    // 2. Şimdi kelimeyi veritabanımızda (SignData) arayalım
    SignData.categorySigns.forEach((categoryId, signs) {
      for (String sign in signs) {
        if (_trToLower(sign) == searchWord) {
          foundSignName = sign;
          foundCategoryId = categoryId;
          break;
        }
      }
    });

    if (foundSignName != null && foundCategoryId != null) {
      // Kelime bulundu! Kelime olarak kuyruğa ekle
      final filename = SignData.getFilename(foundSignName!);
      final item = {
        'name': foundSignName,
        'path': 'assets/gifs/$foundCategoryId/$filename.gif',
        'isLetter': false, // Kelimeler için 3 saniye
      };
      _gifQueue.add(item);
      _historyQueue.add(item);
      _processQueue();
    } else {
      // 2. Kelime BULUNAMADI. Harflere parçala ve harf harf ekle
      final chars = cleanWord.characters;
      for (String char in chars) {
        final upperChar = _trToUpper(char); // Harfler veritabanında büyük harfle kayıtlı
        
        // Harf, 'harfler' kategorisinde var mı?
        if (SignData.categorySigns['harfler']!.contains(upperChar)) {
          final filename = SignData.getFilename(upperChar);
          final item = {
            'name': upperChar,
            'path': 'assets/gifs/harfler/$filename.gif',
            'isLetter': true, // Harfler için 2 saniye
          };
          _gifQueue.add(item);
          _historyQueue.add(item);
        }
      }
      _processQueue(); // Harfleri ekledikten sonra döngüyü tetikle
    }
  }

  void _processQueue() {
    // Eğer zaten bir GIF oynatılıyorsa veya kuyruk boşsa hiçbir şey yapma
    if (_isPlayingGif || _gifQueue.isEmpty) return;
    
    _isPlayingGif = true;
    final item = _gifQueue.removeAt(0); // İlk sıradakini al
    
    final int currentId = ++_playbackId; // Bu oynatmanın kimliği
    
    if (mounted) {
      setState(() {
        _currentSignName = item['name'];
        _currentGifPath = item['path'];
        _currentIsLetter = item['isLetter'];
      });
    }
    
    // Güvenlik (Fallback): Eklenti hata verip onFetchCompleted çağırmazsa sistemi kilitli bırakmamak için 5 saniye maksimum sınır
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isPlayingGif && _playbackId == currentId) {
        _onGifFinished(currentId);
      }
    });
  }

  void _onGifFinished(int id) {
    if (_playbackId != id) return;
    _isPlayingGif = false;
    if (_gifQueue.isNotEmpty && mounted) {
      _processQueue();
    }
  }

  void _replayHistory() {
    if (_historyQueue.isEmpty) return;
    setState(() {
      _playbackId++; // Mevcut oynatmayı anında kes
      _isPlayingGif = false;
      _gifQueue.clear();
      _gifQueue.addAll(_historyQueue);
    });
    _processQueue();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _gifController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).colorScheme.onSurface),
        ),
        title: Text(
          'Sesten İşaret Diline',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: Column(
        children: [
          // Üst Kısım: GIF Oynatıcı
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[200]!, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: _currentGifPath != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Gif(
                              image: AssetImage(_currentGifPath!),
                              key: ValueKey('$_currentGifPath-$_playbackId'),
                              controller: _gifController,
                              fit: BoxFit.contain,
                              autostart: Autostart.no,
                              onFetchCompleted: () {
                                final currentId = _playbackId;
                                _gifController.reset();
                                _gifController.forward().then((_) {
                                  _onGifFinished(currentId);
                                });
                              },
                            ),
                            // Başa Sar Butonu
                            if (_historyQueue.isNotEmpty)
                              Positioned(
                                top: 16,
                                right: 16,
                                child: GestureDetector(
                                  onTap: _replayHistory,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)], // Mavi Turkuaz
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.replay_rounded, color: Colors.white, size: 16),
                                        SizedBox(width: 4),
                                        Text('Başa Sar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sign_language_rounded,
                                size: 80,
                                color: const Color(0xFF2563EB).withOpacity(0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Sistem dinlemeye hazır',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Eşleşen Kelimenin İsmi
          if (_currentSignName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: _currentIsLetter ? const Color(0xFF10B981) : const Color(0xFF2563EB), // Harfse yeşil, Kelimeyse Mavi ton
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (_currentIsLetter ? const Color(0xFF10B981) : const Color(0xFF2563EB)).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: Text(
                  _currentIsLetter ? "Harf: $_currentSignName" : _currentSignName!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

          // Alt Kısım: Açık Tema Dinleme Alanı
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  )
                ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Algılanan Metin
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Text(
                            _recognizedText.isEmpty 
                                ? 'Konuşmaya başlamak için butona dokunun...' 
                                : _recognizedText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _recognizedText.isEmpty 
                                  ? Colors.grey[400] 
                                  : Theme.of(context).colorScheme.onSurface,
                              fontSize: _recognizedText.isEmpty ? 16 : 24,
                              fontWeight: _recognizedText.isEmpty ? FontWeight.normal : FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    // Mikrofon Butonu
                    GestureDetector(
                      onTapDown: (_) => _startListening(),
                      onTapUp: (_) => _stopListening(),
                      onTapCancel: () => _stopListening(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_isListening)
                            AnimatedBuilder(
                              animation: _waveController,
                              builder: (context, child) {
                                return Container(
                                  width: 80 + (_waveController.value * 50),
                                  height: 80 + (_waveController.value * 50),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFEF4444).withOpacity(0.15 - (_waveController.value * 0.15)),
                                  ),
                                );
                              },
                            ),
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: _isListening
                                    ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                    : [const Color(0xFF3B82F6), const Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isListening ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isListening ? 'Dinleniyor...' : 'Basılı Tutarak Konuş',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey[600],
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
