import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String? _predictedSign;
  double? _confidence;
  List<String> _recognizedWords = [];

  CameraController? get controller => _controller;
  List<CameraDescription>? get cameras => _cameras;
  bool get isCameraInitialized => _isCameraInitialized;
  String? get predictedSign => _predictedSign;
  double? get confidence => _confidence;
  List<String> get recognizedWords => _recognizedWords;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _controller!.initialize();
        _isCameraInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Camera Error: $e');
      rethrow;
    }
  }

  Future<void> startImageStream(Function(CameraImage) onFrame) async {
    try {
      if (_isCameraInitialized) {
        await _controller!.startImageStream(onFrame);
      }
    } catch (e) {
      debugPrint('Stream Error: $e');
      rethrow;
    }
  }

  Future<void> stopImageStream() async {
    try {
      if (_isCameraInitialized && _controller != null) {
        await _controller!.stopImageStream();
      }
    } catch (e) {
      debugPrint('Stop Stream Error: $e');
    }
  }

  void updatePrediction(String sign, double conf) {
    _predictedSign = sign;
    _confidence = conf;
    notifyListeners();
  }

  void addRecognizedWord(String word) {
    _recognizedWords.add(word);
    notifyListeners();
  }

  void clearRecognizedWords() {
    _recognizedWords.clear();
    notifyListeners();
  }

  void removeLastWord() {
    if (_recognizedWords.isNotEmpty) {
      _recognizedWords.removeLast();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
