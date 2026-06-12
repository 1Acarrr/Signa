import 'package:flutter/foundation.dart';

class TranslationProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _translationHistory = [];
  int _totalTranslations = 0;

  List<Map<String, dynamic>> get translationHistory => _translationHistory;
  int get totalTranslations => _totalTranslations;

  void addTranslation({
    required String inputType, // 'sign' or 'speech'
    required String outputText,
    required double confidenceScore,
    DateTime? timestamp,
  }) {
    _translationHistory.add({
      'inputType': inputType,
      'outputText': outputText,
      'confidenceScore': confidenceScore,
      'timestamp': timestamp ?? DateTime.now(),
    });
    _totalTranslations++;
    notifyListeners();
  }

  void clearHistory() {
    _translationHistory.clear();
    _totalTranslations = 0;
    notifyListeners();
  }

  List<Map<String, dynamic>> getTranslationsByType(String type) {
    return _translationHistory
        .where((translation) => translation['inputType'] == type)
        .toList();
  }

  void removeTranslation(int index) {
    if (index >= 0 && index < _translationHistory.length) {
      _translationHistory.removeAt(index);
      _totalTranslations--;
      notifyListeners();
    }
  }
}
