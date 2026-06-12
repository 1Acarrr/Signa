import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import '../services/websocket_service.dart';

class SignTranslationScreen extends StatefulWidget {
  const SignTranslationScreen({super.key});

  @override
  State<SignTranslationScreen> createState() => _SignTranslationScreenState();
}

class _SignTranslationScreenState extends State<SignTranslationScreen> {
  CameraController? _cameraController;

  bool _isDetecting = false;
  bool _isModelLoaded = false;
  bool isCameraActive = false;

  String currentPrediction = '';
  double confidence = 0.0;
  int _detectedHandsCount = 0;
  List<String> recognizedLetters = [];

  String? _lastLetter;
  DateTime? _letterStartTime;
  bool _letterAdded = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (mounted) setState(() => _isModelLoaded = false);
      
      final wsService = WebSocketService();
      await wsService.connect();
      
      if (mounted) setState(() => _isModelLoaded = true);

      wsService.stream.listen((data) {
        if (mounted) {
          setState(() {
            currentPrediction = data['label'] ?? '';
            confidence = (data['confidence'] ?? 0.0).toDouble();
            _detectedHandsCount = data['hands'] ?? 0;
            
            if (currentPrediction.isNotEmpty) {
              _handleLetterAssembly(currentPrediction);
            } else {
              _lastLetter = null;
              _letterAdded = false;
            }
          });
        }
      }, onError: (error) {
        debugPrint("WebSocket Hatası: $error");
        if (mounted) setState(() => _isModelLoaded = false);
      }, onDone: () {
        debugPrint("WebSocket Kapandı.");
        if (mounted) setState(() => _isModelLoaded = false);
      });
      
    } catch (e) {
      debugPrint("Bağlantı kurulamadı: $e");
      if (mounted) setState(() => _isModelLoaded = false);
    }
  }

  Future<void> _startCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final camera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      camera,
      ResolutionPreset.low, // Performans için (kasmaması adına) tekrar düşük çözünürlüğe dönüldü
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420, // Ham YUV alıyoruz
    );

    await _cameraController!.initialize();
    await _cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);

    if (mounted) {
      setState(() => isCameraActive = true);
      _cameraController!.startImageStream(_processCameraImage);
    }
  }

  void _toggleCamera() {
    if (isCameraActive) {
      _cameraController?.stopImageStream();
      _cameraController?.dispose();
      _cameraController = null;
      setState(() {
        isCameraActive = false;
        currentPrediction = '';
        confidence = 0.0;
        _detectedHandsCount = 0;
      });
    } else {
      _startCamera();
    }
  }

  void _processCameraImage(CameraImage image) {
    if (!isCameraActive || !_isModelLoaded || !WebSocketService().isConnected) return;
    if (_isDetecting) return; // Ağ gönderimi bitene kadar yeni kare işleme

    _isDetecting = true;

    try {
      // Y kanalını doğrudan ikili (binary) olarak yolla (Sıfır gecikme, JSON yok)
      if (image.planes.isNotEmpty) {
        WebSocketService().sendFrame(image.planes[0].bytes);
      }
    } catch (e) {
      debugPrint("Gönderim hatası: $e");
    } finally {
      // Kısa bir bekleme (Ağı yormamak için saniyede ~20 FPS limiti)
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _isDetecting = false;
      });
    }
  }

  void _handleLetterAssembly(String letter) {
    if (letter == _lastLetter) {
      if (_letterStartTime != null && !_letterAdded &&
          DateTime.now().difference(_letterStartTime!).inMilliseconds > 800) {
        if (letter == "del") {
          if (recognizedLetters.isNotEmpty) recognizedLetters.removeLast();
        } else if (letter == "space") {
          recognizedLetters.add(' ');
        } else if (letter != "nothing") {
          recognizedLetters.add(letter);
        }
        _letterAdded = true;
      }
    } else {
      _lastLetter = letter;
      _letterStartTime = DateTime.now();
      _letterAdded = false;
    }
  }

  void _removeLastLetter() {
    setState(() {
      if (recognizedLetters.isNotEmpty) recognizedLetters.removeLast();
    });
  }

  void _clearAll() {
    setState(() {
      recognizedLetters.clear();
      currentPrediction = '';
      confidence = 0.0;
      _lastLetter = null;
      _letterAdded = false;
    });
  }

  String get _assembledText => recognizedLetters.join();

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _cameraController?.stopImageStream();
    _cameraController?.dispose();
    WebSocketService().disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Sunucu Tabanlı Çeviri'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isModelLoaded
                      ? Colors.green.withValues(alpha: 0.25)
                      : Colors.red.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isModelLoaded ? Colors.greenAccent : Colors.redAccent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isModelLoaded ? Icons.cloud_done : Icons.cloud_off,
                      size: 14,
                      color: _isModelLoaded ? Colors.greenAccent : Colors.redAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isModelLoaded ? 'Sunucuya Bağlı' : 'Sunucu Yok',
                      style: TextStyle(
                        fontSize: 11,
                        color: _isModelLoaded ? Colors.greenAccent : Colors.redAccent,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 420,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (isCameraActive && _cameraController != null && _cameraController!.value.isInitialized)
                    CameraPreview(_cameraController!)
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.videocam_off, size: 64, color: Colors.white38),
                        const SizedBox(height: 12),
                        Text(
                          _isModelLoaded ? 'Başla butonuna basın' : 'Sunucu bekleniyor...',
                          style: const TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),

                  if (currentPrediction.isNotEmpty)
                    Positioned(
                      bottom: 40,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.blueAccent, width: 2),
                            ),
                            child: Text(
                              currentPrediction,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 56,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(confidence * 100).toStringAsFixed(0)}% güven',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Positioned(
                    top: 10,
                    left: 10,
                    child: _infoChip('👋 $_detectedHandsCount el'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isModelLoaded ? _toggleCamera : null,
                    icon: Icon(isCameraActive ? Icons.stop : Icons.play_arrow),
                    label: Text(isCameraActive ? 'Durdur' : 'Başla'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCameraActive ? Colors.redAccent : const Color(0xFF2563EB),
                      disabledBackgroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  IconButton(
                    onPressed: _removeLastLetter,
                    icon: const Icon(Icons.backspace_outlined, size: 32, color: Colors.orangeAccent),
                  ),
                  IconButton(
                    onPressed: _clearAll,
                    icon: const Icon(Icons.delete_sweep, size: 36, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tanınan Metin',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${recognizedLetters.length} harf',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    recognizedLetters.isEmpty
                        ? const Text(
                            'Kamerayı başlatın ve el işaretleri yapın.\n'
                            'Sunucu üzerinden gecikmesiz çalışır.',
                            style: TextStyle(color: Colors.grey, height: 1.6),
                          )
                        : Text(
                            _assembledText,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 2,
                            ),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
      );
}
