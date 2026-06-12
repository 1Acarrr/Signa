import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../../services/websocket_service.dart';

class CameraTranslationSheet extends StatefulWidget {
  final Function(String) onTranslationComplete;

  const CameraTranslationSheet({Key? key, required this.onTranslationComplete}) : super(key: key);

  @override
  State<CameraTranslationSheet> createState() => _CameraTranslationSheetState();
}

class _CameraTranslationSheetState extends State<CameraTranslationSheet> {
  CameraController? _cameraController;

  bool _isDetecting = false;
  bool _isModelLoaded = false;
  bool _isCameraActive = false;

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
    _initializeWebSocket();
    _startCamera();
  }

  @override
  void dispose() {
    _stopCamera();
    WebSocketService().disconnect();
    super.dispose();
  }

  Future<void> _initializeWebSocket() async {
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

            if (confidence > 0.85) {
              _handleLetterAssembly(currentPrediction);
            }
          });
        }
      }, onError: (error) {
        if (mounted) setState(() => _isModelLoaded = false);
      }, onDone: () {
        if (mounted) setState(() => _isModelLoaded = false);
      });
      
    } catch (e) {
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
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _cameraController!.initialize();

    if (mounted) {
      setState(() => _isCameraActive = true);
      _cameraController!.startImageStream(_processCameraImage);
    }
  }

  void _stopCamera() {
    if (_isCameraActive) {
      _cameraController?.stopImageStream();
      _cameraController?.dispose();
      _cameraController = null;
      _isCameraActive = false;
    }
  }

  void _toggleCamera() {
    if (_isCameraActive) {
      _cameraController?.stopImageStream();
      setState(() => _isCameraActive = false);
    } else {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        _cameraController!.startImageStream(_processCameraImage);
        setState(() => _isCameraActive = true);
      } else {
        _startCamera();
      }
    }
  }

  void _processCameraImage(CameraImage image) {
    if (!_isCameraActive || !_isModelLoaded || !WebSocketService().isConnected) return;
    if (_isDetecting) return;

    _isDetecting = true;

    try {
      if (image.planes.isNotEmpty) {
        WebSocketService().sendFrame(image.planes[0].bytes);
      }
    } catch (e) {
      debugPrint("Gönderim hatası: $e");
    } finally {
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

  void _sendToChat() {
    if (recognizedLetters.isNotEmpty) {
      widget.onTranslationComplete(recognizedLetters.join(''));
    }
    Navigator.pop(context);
  }

  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Başlık ve Kapat
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'İşaretten Yazıya Çeviri',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Kamera Alanı
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isModelLoaded ? const Color(0xFF10B981).withOpacity(0.5) : Colors.red.withOpacity(0.5),
                    width: 3,
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_isCameraActive && _cameraController != null && _cameraController!.value.isInitialized)
                      Transform.scale(
                        scale: 1.0,
                        child: Center(
                          child: CameraPreview(_cameraController!),
                        ),
                      )
                    else
                      const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white54, size: 50),
                      ),
                      
                    // Tahmin Göstergesi
                    if (currentPrediction.isNotEmpty && currentPrediction != "nothing")
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: const Color(0xFF10B981), width: 2),
                              ),
                              child: Text(
                                currentPrediction,
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Model ve El bilgisi
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _infoChip(_isModelLoaded ? 'Bağlı' : 'Bağlantı Yok'),
                          const SizedBox(height: 4),
                          _infoChip('${(confidence * 100).toStringAsFixed(0)}% güven'),
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
            ),
          ),
          
          // Kontroller
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isModelLoaded ? _toggleCamera : null,
                  icon: Icon(_isCameraActive ? Icons.stop : Icons.play_arrow),
                  label: Text(_isCameraActive ? 'Durdur' : 'Başla'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCameraActive ? Colors.redAccent : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                ),
                IconButton(
                  onPressed: _removeLastLetter,
                  icon: const Icon(Icons.backspace_outlined, color: Colors.orangeAccent),
                ),
                IconButton(
                  onPressed: _clearAll,
                  icon: const Icon(Icons.delete_sweep, color: Colors.blueGrey),
                ),
              ],
            ),
          ),
          
          // Harfler Paneli
          Container(
            height: 80,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2D2D3A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: recognizedLetters.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                  ),
                  child: Center(
                    child: Text(
                      recognizedLetters[index],
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Çeviri Sonucu & Aksiyon Butonları
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                if (recognizedLetters.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _sendToChat,
                    icon: const Icon(Icons.send),
                    label: const Text('Sohbete Ekle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
