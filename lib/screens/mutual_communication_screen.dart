import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:gif/gif.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import '../services/communication_service.dart';
import '../services/sign_data.dart';
import 'widgets/camera_translation_sheet.dart';

class MutualCommunicationScreen extends StatefulWidget {
  const MutualCommunicationScreen({Key? key}) : super(key: key);

  @override
  State<MutualCommunicationScreen> createState() =>
      _MutualCommunicationScreenState();
}

class _MutualCommunicationScreenState
    extends State<MutualCommunicationScreen> with TickerProviderStateMixin {
  final CommunicationService _communicationService = CommunicationService();

  final TextEditingController _roomCodeController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _isConnected = false;
  bool _inRoom = false;
  bool _isJoining = false;
  bool _showJoinInput = false;
  bool _isCalling = false;
  bool _isWaiting = false; // Oda kuruldu, karşı taraf bekleniyor
  bool _isOptionsSheetOpen = false;
  String _roomId = '';
  String _displayCode = '';
  
  // GIF Kategorileri
  final Map<String, List<String>> _gifCategories = {
    'Duygular': [
      'assets/gifs/duygular/heyecan.gif',
      'assets/gifs/duygular/korkmak.gif',
      'assets/gifs/duygular/kızmak.gif',
      'assets/gifs/duygular/mutlu.gif',
      'assets/gifs/duygular/nefret.gif',
      'assets/gifs/duygular/sevmek.gif',
      'assets/gifs/duygular/yorulmak.gif',
      'assets/gifs/duygular/üzülmek.gif',
      'assets/gifs/duygular/şaşırmak.gif',
    ],
    'Fiiller': [
      'assets/gifs/fiiller/anlamak.gif',
      'assets/gifs/fiiller/bakmak.gif',
      'assets/gifs/fiiller/bilmek.gif',
      'assets/gifs/fiiller/duymak.gif',
      'assets/gifs/fiiller/gelmek.gif',
      'assets/gifs/fiiller/gitmek.gif',
      'assets/gifs/fiiller/görmek.gif',
      'assets/gifs/fiiller/istemek.gif',
      'assets/gifs/fiiller/okumak.gif',
      'assets/gifs/fiiller/yapmak.gif',
    ],
    'İhtiyaçlar': [
      'assets/gifs/günlük-ihtiyaclar/ekmek-tohum-icin.gif',
      'assets/gifs/günlük-ihtiyaclar/ilaç.gif',
      'assets/gifs/günlük-ihtiyaclar/para.gif',
      'assets/gifs/günlük-ihtiyaclar/su.gif',
      'assets/gifs/günlük-ihtiyaclar/yemek.gif',
      'assets/gifs/günlük-ihtiyaclar/şarj.gif',
    ],
    'Kişiler': [
      'assets/gifs/kisiler/anne.gif',
      'assets/gifs/kisiler/arkadas.gif',
      'assets/gifs/kisiler/baba.gif',
      'assets/gifs/kisiler/bebek.gif',
      'assets/gifs/kisiler/doktor.gif',
      'assets/gifs/kisiler/kardeş.gif',
      'assets/gifs/kisiler/polis.gif',
      'assets/gifs/kisiler/çocuk.gif',
      'assets/gifs/kisiler/öğrenci.gif',
      'assets/gifs/kisiler/öğretmen.gif',
    ],
    'İletişim': [
      'assets/gifs/temel-iletisim/günaydın.gif',
      'assets/gifs/temel-iletisim/iyi-geceler.gif',
      'assets/gifs/temel-iletisim/lütfen.gif',
      'assets/gifs/temel-iletisim/merhaba.gif',
      'assets/gifs/temel-iletisim/nasılsın.gif',
      'assets/gifs/temel-iletisim/rica-etmek.gif',
      'assets/gifs/temel-iletisim/selam.gif',
      'assets/gifs/temel-iletisim/teşekkür-etmek.gif',
      'assets/gifs/temel-iletisim/yardım.gif',
      'assets/gifs/temel-iletisim/özür-dilemek.gif',
    ],
  };

  final List<Map<String, String>> _messages = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = '';
  int _processedWordCount = 0;
  bool _speechInitialized = false;

  // GIF Kuyruk Sistemi (speech_to_text_screen ile aynı)
  final List<Map<String, dynamic>> _voiceGifQueue = [];
  final List<Map<String, dynamic>> _voiceHistoryQueue = [];
  bool _voiceIsPlayingGif = false;
  int _voicePlaybackId = 0;
  String? _voiceCurrentGifPath;
  String? _voiceCurrentSignName;
  bool _voiceCurrentIsLetter = false;
  late GifController _voiceGifController;

  // ─── AI, TTS & TASLAK (Staging Area) ─────────────────────────────────────
  final FlutterTts _flutterTts = FlutterTts();
  final List<Map<String, dynamic>> _draftGifs = [];
  bool _isGeneratingSentence = false;
  
  // Lütfen uygulamanızı çalıştırırken kendi anahtarınızı buraya yapıştırın.
  static const String _geminiApiKey = 'BURAYA_GEMINI_API_KEY_YAZILACAK';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _voiceGifController = GifController(vsync: this);
    _initSpeech();
    _initTts();
    _initCommunication();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("tr-TR");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        debugPrint('Speech Status: $status');
        if (status == 'notListening' || status == 'done') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        debugPrint('Speech Error: $error');
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (!mounted) return;
    if (available) {
      _speechInitialized = true;
      debugPrint('Speech initialized: OK');
    } else {
      debugPrint('Speech NOT available!');
    }
  }

  // speech_to_text_screen ile BIREBIR aynı mantık
  void _startListening(StateSetter setModalState) async {
    if (_isListening) return;
    
    // Motor hazır değilse önce hazırla
    if (!_speechInitialized) {
      await _initSpeech();
    }
    
    if (!_speech.isAvailable) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mikrofon kullanılamıyor!')),
      );
      return;
    }
    
    setModalState(() {
      _isListening = true;
      _recognizedText = '';
      _processedWordCount = 0;
      _voiceGifQueue.clear();
      _voiceHistoryQueue.clear();
      _voicePlaybackId++;
      _voiceIsPlayingGif = false;
      _voiceCurrentGifPath = null;
      _voiceCurrentSignName = null;
    });
    
    _speech.listen(
      onResult: (val) {
        if (mounted) {
          setModalState(() {
            _recognizedText = val.recognizedWords;
          });
          _voiceExtractNewWords(val.recognizedWords, setModalState);
        }
      },
      localeId: 'tr_TR',
      partialResults: true,
      listenMode: stt.ListenMode.dictation,
    );
  }

  // El kaldırınca sadece durdur, paneli kapatma!
  void _stopListeningOnly(StateSetter setModalState) {
    if (!_isListening) return;
    setModalState(() => _isListening = false);
    _speech.stop();
  }

  void _initCommunication() {
    _communicationService.onRoomCreated = (code) {
      setState(() {
        _displayCode = code;
        _roomId = code;
        _isCalling = false;
        _isWaiting = true;  // Kodu göster, karşı tarafı bekle
        _inRoom = false;    // Henüz video ekranına geçme
      });
    };

    _communicationService.onRoomReady = () {
      setState(() {
        _isWaiting = false;
        _inRoom = true;  // Sohbet ekranına geç
      });
    };

    _communicationService.onMessageReceived = (type, content, isMe) {
      if (!mounted) return;
      if (isMe) return; // Kendi mesajlarımızı zaten _sendMessage'de ekliyoruz
      setState(() {
        _messages.add({
          'sender': 'Karşı Taraf',
          'type': type,
          'content': content,
        });
      });
    };

    _communicationService.onError = (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      setState(() {
        _isCalling = false;
        _isJoining = false;
      });
    };

    _communicationService.onPeerDisconnected = () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Karşı taraf ayrıldı.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _inRoom = false;
        _isWaiting = false;
        _displayCode = '';
        _messages.clear();
      });
    };

    setState(() => _isConnected = true);
  }

  @override
  void dispose() {
    _communicationService.hangUp();
    _roomCodeController.dispose();
    _messageController.dispose();
    _voiceGifController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() => _isCalling = true);
    await _communicationService.createRoom();
  }

  Future<void> _joinRoom() async {
    final code = _roomCodeController.text.trim();
    if (code.length < 6) return;
    setState(() => _isJoining = true);
    await _communicationService.joinRoom(code);
    setState(() {
      _isJoining = false;
      _displayCode = code;
      _roomId = code;
    });
  }

  void _sendMessage() {
    if (_roomId.isEmpty) return;
    
    final text = _messageController.text.trim();

    // Hem metin yok hem de taslak boşsa hiçbir şey yapma
    if (text.isEmpty && _draftGifs.isEmpty) return;

    // Eğer sepette GIF varsa, onları ve metni (varsa) tek bir gif_sequence olarak yolla
    if (_draftGifs.isNotEmpty) {
      final gifs = _draftGifs.map((g) => {'name': g['label'], 'path': g['path']}).toList();
      final content = jsonEncode({
        'text': text, // İstersek boş olabilir, istersek yazılmış olabilir
        'gifs': gifs,
      });
      
      _messageController.clear();
      _communicationService.sendMessage('gif_sequence', content);
      setState(() {
        _messages.add({'sender': 'Ben', 'type': 'gif_sequence', 'content': content});
        _draftGifs.clear();
      });
      return;
    }

    // Sadece metin varsa
    if (text.isNotEmpty) {
      _messageController.clear();
      _communicationService.sendMessage('text', text);
      setState(() {
        _messages.add({'sender': 'Ben', 'type': 'text', 'content': text});
      });
    }
  }

  void _sendGifMessage(String gifPath) {
    if (_roomId.isEmpty) return;
    
    // ANINDA GÖNDERMEK YERİNE TASLAĞA (SEPETE) EKLE
    final label = gifPath.split('/').last.replaceAll('.gif', '').replaceAll('-', ' ').toUpperCase();
    setState(() {
      _draftGifs.add({
        'path': gifPath,
        'label': label,
      });
    });
  }

  // --- GEMINI ILE CÜMLE KURMA (LLM) ---
  Future<void> _generateAndSendSentence() async {
    if (_draftGifs.isEmpty) return;
    
    if (_geminiApiKey.isEmpty || _geminiApiKey == 'BURAYA_GEMINI_API_KEY_YAZILACAK') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen kod içindeki Gemini API Key alanını doldurun!')),
      );
      return;
    }
    
    setState(() => _isGeneratingSentence = true);
    
    try {
      final model = GenerativeModel(model: 'gemini-3.5-flash', apiKey: _geminiApiKey);
      final words = _draftGifs.map((g) => g['label']).join(', ');
      final prompt = 'Sen bir işaret dili çevirmenisin. İşitme engelli bir kullanıcının peş peşe yaptığı işaretlerin kök kelimeleri aşağıda verilmiştir. Görevin, bu kök kelimeleri doğal, günlük konuşma dilinde, kurallı ve nazik tek bir Türkçe cümleye çevirmektir. Cümleyi oluştururken kelimelerin sırasını ve niyetini koru, gerekirse uygun ekler (zaman, kişi ekleri) ekle. SADECE oluşturduğun cümleyi ver, hiçbir açıklama veya tırnak işareti ekleme.\nKelimeler: $words';
      
      final response = await model.generateContent([Content.text(prompt)]);
      String sentence = response.text?.trim() ?? words;
      
      if (sentence.isNotEmpty) {
        // 1. Sese Çevir
        await _flutterTts.speak(sentence);
        
        // 2. GIF'leri ve Cümleyi Tek Mesajda Birleştir (gif_sequence)
        final gifs = _draftGifs.map((g) => {'name': g['label'], 'path': g['path']}).toList();
        final content = jsonEncode({
          'text': sentence,
          'gifs': gifs,
        });

        _communicationService.sendMessage('gif_sequence', content);
        
        // 3. Ekrana Ekle ve Taslağı Temizle
        setState(() {
          _messages.add({
            'sender': 'Ben',
            'type': 'gif_sequence',
            'content': content,
          });
          _draftGifs.clear();
        });
      }
    } catch (e, stackTrace) {
      print('Yapay Zeka Hatası Detayı: $e');
      print('Stack Trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Yapay Zeka Hatası: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGeneratingSentence = false);
      }
    }
  }

  // Sesten İşarete Çeviri: Algılanan metinden GIF yollarını çıkartma
  List<Map<String, dynamic>> _extractGifsFromText(String text) {
    List<Map<String, dynamic>> extractedGifs = [];
    if (text.isEmpty) return extractedGifs;

    final words = text.trim().split(RegExp(r'\s+'));
    for (String word in words) {
      final safeLower = word.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
      final cleanWord = safeLower.replaceAll(RegExp(r'[^\w\sğüşöçıi]'), '').trim();
      if (cleanWord.isEmpty) continue;

      String searchWord = cleanWord;
      if (SignData.wordRoots.containsKey(cleanWord)) {
        searchWord = SignData.wordRoots[cleanWord]!.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();
      }
      
      String? foundSignName;
      String? foundCategoryId;
      
      SignData.categorySigns.forEach((categoryId, signs) {
        if (foundSignName != null) return;
        for (String sign in signs) {
          if (sign.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase() == searchWord) {
            foundSignName = sign;
            foundCategoryId = categoryId;
            break;
          }
        }
      });

      if (foundSignName != null && foundCategoryId != null) {
        final filename = SignData.getFilename(foundSignName!);
        extractedGifs.add({
          'name': foundSignName,
          'path': 'assets/gifs/$foundCategoryId/$filename.gif',
        });
      } else {
        final chars = cleanWord.characters;
        for (String char in chars) {
          final upperChar = char.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
          if (SignData.categorySigns['harfler']!.contains(upperChar)) {
            final filename = SignData.getFilename(upperChar);
            extractedGifs.add({
              'name': upperChar,
              'path': 'assets/gifs/harfler/$filename.gif',
            });
          }
        }
      }
    }
    return extractedGifs;
  }

  void _sendGifSequence() {
    if (_recognizedText.isEmpty || _roomId.isEmpty) return;
    
    final gifs = _extractGifsFromText(_recognizedText);
    if (gifs.isEmpty) return;

    final content = jsonEncode({
      'text': _recognizedText,
      'gifs': gifs,
    });

    _communicationService.sendMessage('gif_sequence', content);
    
    setState(() {
      _messages.add({
        'sender': 'Ben',
        'type': 'gif_sequence',
        'content': content,
      });
      _recognizedText = '';
    });
  }

  // ─── GIF Kuyruk Sistemi (speech_to_text_screen ile birebir) ─────────────────
  String _trToLower(String text) =>
      text.replaceAll('I', 'ı').replaceAll('İ', 'i').toLowerCase();

  String _trToUpper(String text) =>
      text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();

  void _voiceExtractNewWords(String text, StateSetter setModalState) {
    if (text.isEmpty) return;
    final currentWords = text.trim().split(RegExp(r'\s+'));
    if (currentWords.length > _processedWordCount) {
      final newWords = currentWords.sublist(_processedWordCount);
      _processedWordCount = currentWords.length;
      for (String w in newWords) _voiceQueueWord(w, setModalState);
    } else if (currentWords.length < _processedWordCount) {
      _processedWordCount = currentWords.length;
      _voiceGifQueue.clear();
      _voicePlaybackId++;
      _voiceIsPlayingGif = false;
      for (String w in currentWords) _voiceQueueWord(w, setModalState);
    }
  }

  void _voiceQueueWord(String word, StateSetter setModalState) {
    final safeLower = _trToLower(word);
    final cleanWord = safeLower.replaceAll(RegExp(r'[^\w\sğüşöçıi]'), '').trim();
    if (cleanWord.isEmpty) return;

    String? foundSignName;
    String? foundCategoryId;

    String searchWord = cleanWord;
    if (SignData.wordRoots.containsKey(cleanWord)) {
      searchWord = _trToLower(SignData.wordRoots[cleanWord]!);
    }

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
      final filename = SignData.getFilename(foundSignName!);
      final item = {
        'name': foundSignName!,
        'path': 'assets/gifs/$foundCategoryId/$filename.gif',
        'isLetter': false,
      };
      _voiceGifQueue.add(item);
      _voiceHistoryQueue.add(item);
      _voiceProcessQueue(setModalState);
    } else {
      final chars = cleanWord.characters;
      for (String char in chars) {
        final upperChar = _trToUpper(char);
        if (SignData.categorySigns['harfler']!.contains(upperChar)) {
          final filename = SignData.getFilename(upperChar);
          final item = {
            'name': upperChar,
            'path': 'assets/gifs/harfler/$filename.gif',
            'isLetter': true,
          };
          _voiceGifQueue.add(item);
          _voiceHistoryQueue.add(item);
        }
      }
      _voiceProcessQueue(setModalState);
    }
  }

  void _voiceProcessQueue(StateSetter setModalState) {
    if (_voiceIsPlayingGif || _voiceGifQueue.isEmpty) return;
    _voiceIsPlayingGif = true;
    final item = _voiceGifQueue.removeAt(0);
    final int currentId = ++_voicePlaybackId;
    try {
      setModalState(() {
        _voiceCurrentSignName = item['name'];
        _voiceCurrentGifPath = item['path'];
        _voiceCurrentIsLetter = item['isLetter'];
      });
    } catch (e) {
      // Modal kapandığı için yoksay
      return;
    }
    // Maks 5 saniye sonra sıradakine geç
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _voiceIsPlayingGif && _voicePlaybackId == currentId) {
        _voiceOnGifFinished(currentId, setModalState);
      }
    });
  }

  void _voiceOnGifFinished(int id, StateSetter setModalState) {
    if (_voicePlaybackId != id) return;
    _voiceIsPlayingGif = false;
    if (_voiceGifQueue.isNotEmpty && mounted) _voiceProcessQueue(setModalState);
  }

  void _voiceReplayHistory(StateSetter setModalState) {
    if (_voiceHistoryQueue.isEmpty) return;
    try {
      setModalState(() {
        _voicePlaybackId++;
        _voiceIsPlayingGif = false;
        _voiceGifQueue.clear();
        _voiceGifQueue.addAll(_voiceHistoryQueue);
      });
      _voiceProcessQueue(setModalState);
    } catch (e) {
      // yoksay
    }
  }

  void _toggleOptionsSheet() {
    setState(() {
      _isOptionsSheetOpen = !_isOptionsSheetOpen;
    });
  }

  void _showVoiceTranslationSheet() {
    // Sesi durdurup değişkenleri sıfırla
    _speech.stop();
    _isListening = false;
    _recognizedText = '';
    _processedWordCount = 0;
    _voiceGifQueue.clear();
    _voiceHistoryQueue.clear();
    _voiceIsPlayingGif = false;
    _voiceCurrentGifPath = null;
    _voiceCurrentSignName = null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bgColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
          return Container(
            height: MediaQuery.of(context).size.height * 0.80,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 24, spreadRadius: 5),
              ],
            ),
            child: Column(
              children: [
                // ── Başlık & Kapat ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sesten İşarete Çeviri',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _speech.stop();
                          setModalState(() => _isListening = false);
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // ── GIF Alanı ──────────────────────────────────────────────────
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2D2D3A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (_voiceCurrentGifPath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Gif(
                                image: AssetImage(_voiceCurrentGifPath!),
                                key: ValueKey('$_voiceCurrentGifPath-$_voicePlaybackId'),
                                controller: _voiceGifController,
                                autostart: Autostart.no,
                                onFetchCompleted: () {
                                  final currentId = _voicePlaybackId;
                                  _voiceGifController.reset();
                                  _voiceGifController.forward().then((_) {
                                    _voiceOnGifFinished(currentId, setModalState);
                                  });
                                },
                                fit: BoxFit.contain,
                              ),
                            )
                          else
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sign_language_rounded,
                                  size: 70,
                                  color: const Color(0xFF2563EB).withOpacity(0.2),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Dinlemeye hazır',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                          // İşaret adı
                          if (_voiceCurrentSignName != null)
                            Positioned(
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _voiceCurrentIsLetter
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF2563EB),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_voiceCurrentIsLetter
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFF2563EB))
                                          .withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Text(
                                  _voiceCurrentIsLetter
                                      ? 'Harf: $_voiceCurrentSignName'
                                      : _voiceCurrentSignName!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                          // Başa Sar
                          if (_voiceHistoryQueue.isNotEmpty)
                            Positioned(
                              top: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () => _voiceReplayHistory(setModalState),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0EA5E9).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.replay_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Başa Sar',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Algılanan Metin ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _recognizedText.isEmpty
                        ? 'Basılı tutarak konuşun...'
                        : _recognizedText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _recognizedText.isEmpty ? Colors.grey[400] : Theme.of(context).colorScheme.onSurface,
                      fontSize: _recognizedText.isEmpty ? 14 : 18,
                      fontWeight: _recognizedText.isEmpty ? FontWeight.normal : FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Mikrofon Butonu ────────────────────────────────────────────
                Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (_) => _startListening(setModalState),
                  onPointerUp: (_) => _stopListeningOnly(setModalState),
                  onPointerCancel: (_) => _stopListeningOnly(setModalState),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _isListening ? 90 : 72,
                    height: _isListening ? 90 : 72,
                    decoration: BoxDecoration(
                      color: _isListening ? Colors.redAccent : const Color(0xFF2563EB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.redAccent : const Color(0xFF2563EB)).withOpacity(0.4),
                          blurRadius: _isListening ? 30 : 15,
                          spreadRadius: _isListening ? 10 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                      color: Colors.white,
                      size: _isListening ? 44 : 32,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _isListening ? 'Dinleniyor...' : 'Basılı Tutarak Konuş',
                    style: TextStyle(
                      color: _isListening ? Colors.redAccent : Colors.grey[600],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Gönder / İptal Butonları ──────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            _speech.stop();
                            setModalState(() => _isListening = false);
                            Navigator.pop(ctx);
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('İptal', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _recognizedText.isEmpty
                              ? null
                              : () {
                                  _speech.stop();
                                  _sendGifSequence();
                                  Navigator.pop(ctx);
                                },
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          label: const Text(
                            'Sohbete Gönder',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCameraTranslationSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (ctx) => CameraTranslationSheet(
        onTranslationComplete: (String text) {
          if (text.trim().isEmpty) return;
          
          // Direkt yazılı mesaj olarak gönder
          if (_roomId.isNotEmpty) {
            _communicationService.sendMessage('text', text.trim());
          }
          
          setState(() {
            _messages.add({
              'sender': 'Ben',
              'type': 'text',
              'content': text.trim(),
            });
          });
        },
      ),
    );
  }

  void _showGifPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _buildGifPickerPanel(),
    );
  }

  Widget _buildGifPickerPanel() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1E1E2C) 
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: DefaultTabController(
        length: _gifCategories.keys.length,
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            TabBar(
              isScrollable: true,
              labelColor: const Color(0xFF2563EB),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF2563EB),
              tabs: _gifCategories.keys
                  .map((category) => Tab(text: category))
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                children: _gifCategories.keys.map((category) {
                  final gifs = _gifCategories[category]!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: gifs.length,
                    itemBuilder: (context, index) {
                      final path = gifs[index];
                      // Dosya isminden etiketi çıkar
                      final label = path.split('/').last.replaceAll('.gif', '').replaceAll('-', ' ');
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Paneli kapat
                          _sendGifMessage(path); // GIF gönder
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(path, fit: BoxFit.cover),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  color: Colors.black.withOpacity(0.6),
                                  child: Text(
                                    label.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Lobby Ekranı ─────────────────────────────────────────────────────────
  Widget _buildLobby() {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  // Görsel
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/images/mutual_communication.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.video_call,
                        size: 120,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ── Yeni Oda Kur ──────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isCalling ? null : _createRoom,
                      icon: _isCalling
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        _isCalling ? 'Oda Oluşturuluyor...' : 'Yeni Oda Kur',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'VEYA',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Odaya Katıl ───────────────────────────────────────────
                  if (!_showJoinInput)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => setState(() => _showJoinInput = true),
                        icon: const Icon(Icons.login, color: Colors.white),
                        label: const Text(
                          'Odaya Katıl',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),

                  if (_showJoinInput)
                    Column(
                      children: [
                        TextField(
                          controller: _roomCodeController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            letterSpacing: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: '000000',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              letterSpacing: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => setState(() {
                                  _showJoinInput = false;
                                  _roomCodeController.clear();
                                }),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'İptal',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (_isCalling || _isJoining) ? null : _joinRoom,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isJoining
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Katıl',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Oda Kodu Paylaşım Ekranı (oda oluşturuldu, karşı taraf bekleniyor) ───
  Widget _buildWaitingScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 32),
            const Text(
              'Arkadaşınızı Bekliyor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bu kodu arkadaşınızla paylaşın:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Kodu büyük göster + kopyala
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _displayCode,
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 12,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.copy, size: 18, color: Color(0xFF2563EB)),
                    label: const Text('Kopyala', style: TextStyle(color: Color(0xFF2563EB))),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _displayCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kod kopyalandı!')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Mesajlaşma Odası Ekranı ─────────────────────────────────────────────
  Widget _buildVideoChat() {
    return Column(
      children: [
        // Mesajlaşma alanı (Tam Ekran Tasarım)
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF1E1E2C) 
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: _messages.length,
                    itemBuilder: (ctx, i) {
                      final msg = _messages[i];
                      final isMe = msg['sender'] == 'Ben';
                      final isGif = msg['type'] == 'gif';
                      final isGifSequence = msg['type'] == 'gif_sequence';
                      
                      if (isGifSequence) {
                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GifSequencePlayer(messageContent: msg['content']?.toString() ?? '', isMe: isMe),
                          ),
                        );
                      }
                      
                      return Align(
                        alignment: isMe
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: isGif 
                            ? EdgeInsets.zero 
                            : const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                          decoration: BoxDecoration(
                            color: isGif 
                                ? Colors.transparent
                                : (isMe
                                    ? const Color(0xFF2563EB)
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF2D2D3A)
                                        : Colors.white),
                            boxShadow: isGif ? [] : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              )
                            ],
                            borderRadius: BorderRadius.circular(isGif ? 16 : 20).copyWith(
                              bottomRight: isMe
                                  ? const Radius.circular(4)
                                  : Radius.circular(isGif ? 16 : 20),
                              bottomLeft: !isMe
                                  ? const Radius.circular(4)
                                  : Radius.circular(isGif ? 16 : 20),
                            ),
                          ),
                          clipBehavior: isGif ? Clip.hardEdge : Clip.none,
                          child: isGif
                              ? Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.asset(
                                      msg['content'] ?? '',
                                      width: 160,
                                      height: 160,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Padding(
                                        padding: EdgeInsets.all(32),
                                        child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                      ),
                                    ),
                                  ),
                                )
                              : Text(
                                  msg['content'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isMe
                                        ? Colors.white
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                if (_isOptionsSheetOpen)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(
                            heroTag: 'gifBtnInline',
                            mini: true,
                            backgroundColor: const Color(0xFF2563EB),
                            child: const Icon(Icons.gif_box, color: Colors.white, size: 24),
                            onPressed: () {
                              _toggleOptionsSheet();
                              _showGifPicker();
                            },
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'micBtnInline',
                            mini: true,
                            backgroundColor: Colors.redAccent,
                            child: const Icon(Icons.mic, color: Colors.white, size: 24),
                            onPressed: () {
                              _toggleOptionsSheet();
                              _showVoiceTranslationSheet();
                            },
                          ),
                          const SizedBox(height: 8),
                          FloatingActionButton(
                            heroTag: 'cameraBtnInline',
                            mini: true,
                            backgroundColor: const Color(0xFF10B981), // Emerald green
                            child: const Icon(Icons.videocam, color: Colors.white, size: 24),
                            onPressed: () {
                              _toggleOptionsSheet();
                              _showCameraTranslationSheet();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // ─── TASLAK (STAGING AREA) ─────────────────────────────────
                if (_draftGifs.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2D3A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Seçilen İşaretler:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 70,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _draftGifs.length,
                            itemBuilder: (ctx, i) {
                              final gif = _draftGifs[i];
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.asset(gif['path'], width: 70, height: 70, fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => setState(() => _draftGifs.removeAt(i)),
                                        child: Container(
                                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0, left: 0, right: 0,
                                      child: Container(
                                        color: Colors.black54,
                                        child: Text(gif['label'], style: const TextStyle(color: Colors.white, fontSize: 9), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isGeneratingSentence ? null : _generateAndSendSentence,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isGeneratingSentence 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Cümle Kur ve Gönder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                Container(
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 24, top: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF1E1E2C) 
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isOptionsSheetOpen ? Icons.close : Icons.add, 
                            color: const Color(0xFF2563EB), 
                            size: 28
                          ),
                          onPressed: _toggleOptionsSheet,
                          tooltip: 'Seçenekler',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Bir mesaj yazın...',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: Theme.of(context).brightness == Brightness.dark 
                                ? const Color(0xFF2D2D3A) 
                                : const Color(0xFFF1F5F9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (!_isConnected) {
      body = const Center(child: CircularProgressIndicator());
    } else if (!_inRoom && !_isWaiting) {
      body = _buildLobby();
    } else if (_isWaiting) {
      body = _buildWaitingScreen();
    } else {
      body = _buildVideoChat();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Karşılıklı İletişim'),
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () async {
            await _communicationService.hangUp();
            if (mounted) context.go('/home');
          },
        ),
      ),
      body: body,
    );
  }
}

class GifSequencePlayer extends StatefulWidget {
  final String messageContent;
  final bool isMe;

  const GifSequencePlayer({Key? key, required this.messageContent, required this.isMe}) : super(key: key);

  @override
  State<GifSequencePlayer> createState() => _GifSequencePlayerState();
}

class _GifSequencePlayerState extends State<GifSequencePlayer> with TickerProviderStateMixin {
  late GifController _gifController;
  List<Map<String, dynamic>> _gifs = [];
  String _text = '';
  
  bool _isPlaying = false;
  int _currentIndex = 0;
  int _playbackId = 0;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
    _parseMessage();
    _startSequence();
  }

  void _parseMessage() {
    try {
      final data = jsonDecode(widget.messageContent);
      _text = data['text'] ?? '';
      _gifs = List<Map<String, dynamic>>.from(data['gifs'] ?? []);
    } catch (e) {
      debugPrint('JSON Parse Error: $e');
    }
  }

  void _startSequence() {
    if (_gifs.isEmpty) return;
    setState(() {
      _currentIndex = 0;
      _playbackId++;
      _isPlaying = false;
    });
    _playNext();
  }

  void _playNext() {
    if (_currentIndex >= _gifs.length) {
      if (mounted) setState(() => _isPlaying = false);
      return;
    }
    _isPlaying = true;
    if (mounted) setState(() {});
    // GIF widget'ının onFetchCompleted tetikleyeceği GifController.forward().then() yeterli
    // Burada ayrı bir timer yok - speech_to_text_screen ile aynı mantık
  }

  void _onGifFinished(int id) {
    if (_playbackId != id || !mounted) return;
    setState(() {
      _currentIndex++;
      _isPlaying = _currentIndex < _gifs.length;
    });
    if (_currentIndex < _gifs.length) _playNext();
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gifs.isEmpty) return const SizedBox();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.isMe
        ? const Color(0xFF2563EB)
        : (isDark ? const Color(0xFF2D2D3A) : Colors.white);
    final textColor = widget.isMe ? Colors.white : (isDark ? Colors.white : Colors.black87);

    final currentGif = _currentIndex < _gifs.length ? _gifs[_currentIndex] : _gifs.last;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(20),
          bottomLeft: !widget.isMe ? const Radius.circular(4) : const Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // GIF Alanı
          Stack(
            children: [
              Container(
                height: 160,
                color: isDark ? Colors.black26 : Colors.black12,
                child: Center(
                  child: Gif(
                    image: AssetImage(currentGif['path']),
                    key: ValueKey('${currentGif['path']}-$_playbackId-$_currentIndex'),
                    controller: _gifController,
                    fit: BoxFit.cover,
                    autostart: Autostart.no,
                    onFetchCompleted: () {
                      final currentId = _playbackId;
                      _gifController.reset();
                      _gifController.forward().then((_) {
                        _onGifFinished(currentId);
                      });
                    },
                  ),
                ),
              ),
              // Başa Sar Butonu
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _startSequence,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.replay, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Başa Sar', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              // İsim Etiketi
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    currentGif['name'] ?? '',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          // Metin Alanı
          if (_text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                _text,
                style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
        ],
      ),
    );
  }
}
