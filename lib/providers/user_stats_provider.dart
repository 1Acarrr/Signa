import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStatsProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  int _totalTranslations = 0;
  int _learnedSigns = 0;
  int _practiceSuccessRate = 0; // 0 to 100
  
  int _totalPracticeAttempts = 0;
  int _successfulPracticeAttempts = 0;

  UserStatsProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadStats();
  }

  void _loadStats() {
    if (_prefs == null) return;
    
    _totalTranslations = _prefs!.getInt('stats_totalTranslations') ?? 0;
    _learnedSigns = _prefs!.getInt('stats_learnedSigns') ?? 0;
    _practiceSuccessRate = _prefs!.getInt('stats_practiceSuccessRate') ?? 0;
    _totalPracticeAttempts = _prefs!.getInt('stats_totalPracticeAttempts') ?? 0;
    _successfulPracticeAttempts = _prefs!.getInt('stats_successfulPracticeAttempts') ?? 0;
    
    notifyListeners();
  }

  // Getters
  int get totalTranslations => _totalTranslations;
  int get learnedSigns => _learnedSigns;
  int get practiceSuccessRate => _practiceSuccessRate;

  // Çeviri yapıldıkça artır
  Future<void> incrementTranslation() async {
    _totalTranslations++;
    await _prefs?.setInt('stats_totalTranslations', _totalTranslations);
    notifyListeners();
  }

  // Yeni kelime öğrenildiğinde (Örn: Öğrenme modüllerinden geçildiğinde)
  Future<void> addLearnedSign(int count) async {
    _learnedSigns += count;
    await _prefs?.setInt('stats_learnedSigns', _learnedSigns);
    notifyListeners();
  }

  // Pratik testleri sonuçlandığında başarı oranını soru bazlı güncelle
  Future<void> updatePracticeSuccess(int correctAnswers, int totalQuestions) async {
    _totalPracticeAttempts += totalQuestions;
    _successfulPracticeAttempts += correctAnswers;
    
    if (_totalPracticeAttempts > 0) {
      _practiceSuccessRate = ((_successfulPracticeAttempts / _totalPracticeAttempts) * 100).round();
    }
    
    await _prefs?.setInt('stats_totalPracticeAttempts', _totalPracticeAttempts);
    await _prefs?.setInt('stats_successfulPracticeAttempts', _successfulPracticeAttempts);
    await _prefs?.setInt('stats_practiceSuccessRate', _practiceSuccessRate);
    
    notifyListeners();
  }
}
