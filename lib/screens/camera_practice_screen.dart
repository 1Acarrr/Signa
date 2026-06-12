import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/websocket_service.dart';
import '../providers/user_stats_provider.dart';
import '../config/theme.dart';

class CameraPracticeScreen extends StatefulWidget {
  final String targetSign;
  final String gifPath;

  const CameraPracticeScreen({
    Key? key,
    required this.targetSign,
    required this.gifPath,
  }) : super(key: key);

  @override
  State<CameraPracticeScreen> createState() => _CameraPracticeScreenState();
}

class _CameraPracticeScreenState extends State<CameraPracticeScreen> {
  CameraController? _cameraController;

  bool _isModelLoaded = false;
  bool _isCameraActive = false;
  bool _isDetecting = false;
  bool _isLearned = false;

  String currentPrediction = '';
  double confidence = 0.0;
  int _successFramesCount = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initializeWebSocket();
    _startCamera();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
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
        if (mounted && !_isLearned) {
          setState(() {
            currentPrediction = data['label'] ?? '';
            confidence = (data['confidence'] ?? 0.0).toDouble();

            // Sadece %50 üzeri güvenilirlik ile eşleşme aranıyor
            if (currentPrediction.toLowerCase() == widget.targetSign.toLowerCase()) {
              if (confidence > 0.50) {
                _successFramesCount++;
                // 3 kare üst üste (yaklaşık 1 saniye) doğru yaparsa kabul et
                if (_successFramesCount >= 3) {
                  _handleSuccess();
                }
              }
            } else if (currentPrediction.isNotEmpty) {
              // Farklı bir işaret yapıldığında sayacı sıfırla
              _successFramesCount = 0;
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
    await _cameraController!.lockCaptureOrientation(DeviceOrientation.portraitUp);

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

  void _processCameraImage(CameraImage image) {
    if (!_isCameraActive || !_isModelLoaded || !WebSocketService().isConnected) return;
    if (_isDetecting || _isLearned) return;

    _isDetecting = true;

    try {
      if (image.planes.isNotEmpty) {
        WebSocketService().sendFrame(image.planes[0].bytes);
      }
    } catch (e) {
      debugPrint("Gönderim hatası: $e");
    } finally {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _isDetecting = false;
      });
    }
  }

  void _handleSuccess() {
    _isLearned = true;
    _stopCamera();
    
    // Profili güncelle
    Provider.of<UserStatsProvider>(context, listen: false).addLearnedSign(1);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            ),
            const SizedBox(height: 24),
            const Text(
              'Harika!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              '"${widget.targetSign}" işaretini başarıyla öğrendiniz. Profilinizdeki öğrenilen işaret sayısı artırıldı.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Kapat Dialog
                  Navigator.pop(context); // Kapat Practice Screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Devam Et', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${widget.targetSign} Harfi Pratiği'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Kamera Akışı
          if (_isCameraActive && _cameraController != null && _cameraController!.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize?.height ?? 1,
                  height: _cameraController!.value.previewSize?.width ?? 1,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),
            
          // Karartma Gradiyentleri
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
            ),
          ),
          
          // Hedef Göstergesi ve Durum
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _isModelLoaded ? Colors.green.withOpacity(0.8) : Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isModelLoaded ? Icons.cloud_done : Icons.cloud_off,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isModelLoaded ? 'Yapay Zeka Aktif' : 'Sunucu Bekleniyor...',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Yapılması İstenen İşaret ve Gelen Tahmin
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                Row(
                  children: [
                    // Hedef Harf (Kopya)
                    Expanded(
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Hedef İşaret', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              widget.targetSign,
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Sizin Yaptığınız (AI Tahmini)
                    Expanded(
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: currentPrediction.toLowerCase() == widget.targetSign.toLowerCase() 
                              ? Colors.green 
                              : const Color(0xFF1F2937),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: currentPrediction.toLowerCase() == widget.targetSign.toLowerCase() 
                                ? Colors.greenAccent 
                                : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sizin Yaptığınız', 
                              style: TextStyle(
                                color: currentPrediction.toLowerCase() == widget.targetSign.toLowerCase() 
                                    ? Colors.white 
                                    : Colors.white54, 
                                fontSize: 12
                              )
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentPrediction.isEmpty ? '?' : currentPrediction,
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                // İpucu Resmi (Küçük)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          widget.gifPath,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'İpucu: Ekrandaki işareti\nkameraya gösterin',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
