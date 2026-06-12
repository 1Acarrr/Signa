import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_stats_provider.dart';
import '../services/sign_data.dart';
import 'widgets/restricted_access_view.dart';
import '../config/theme.dart';

class QuizQuestion {
  final String correctSign;
  final String gifPath;
  final List<String> options;

  QuizQuestion({required this.correctSign, required this.gifPath, required this.options});
}

class PracticeTestScreen extends StatefulWidget {
  final String categoryId;
  const PracticeTestScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  State<PracticeTestScreen> createState() => _PracticeTestScreenState();
}

class _PracticeTestScreenState extends State<PracticeTestScreen> {
  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  
  bool _hasAnswered = false;
  String? _selectedAnswer;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  void _generateQuiz() {
    final random = Random();
    List<QuizQuestion> newQuestions = [];
    
    List<Map<String, String>> availableSigns = [];
    
    // Kategori kontrolü
    if (widget.categoryId == 'all') {
      SignData.categorySigns.forEach((catId, signs) {
        for (var sign in signs) {
          final filename = SignData.getFilename(sign);
          availableSigns.add({'sign': sign, 'path': 'assets/gifs/$catId/$filename.gif'});
        }
      });
    } else {
      final signs = SignData.categorySigns[widget.categoryId] ?? [];
      for (var sign in signs) {
        final filename = SignData.getFilename(sign);
        availableSigns.add({'sign': sign, 'path': 'assets/gifs/${widget.categoryId}/$filename.gif'});
      }
    }

    // Seçilen kategori yeterli kelimeye sahip değilse sayıyı sınırla
    int questionCount = min(10, availableSigns.length);
    availableSigns.shuffle(random);
    final selectedSigns = availableSigns.take(questionCount).toList();

    // Yanlış şıklar havuzunu oluştur
    List<String> optionPool = [];
    if (widget.categoryId == 'all') {
      SignData.categorySigns.values.forEach((list) => optionPool.addAll(list));
    } else {
      optionPool = List<String>.from(SignData.categorySigns[widget.categoryId] ?? []);
    }

    for (var signData in selectedSigns) {
      String correctSign = signData['sign']!;
      String path = signData['path']!;

      List<String> wrongOptions = optionPool.where((s) => s != correctSign).toList();
      wrongOptions.shuffle(random);
      List<String> options = [correctSign, ...wrongOptions.take(3)];
      options.shuffle(random);

      newQuestions.add(QuizQuestion(correctSign: correctSign, gifPath: path, options: options));
    }

    setState(() {
      _questions = newQuestions;
      _currentIndex = 0;
      _score = 0;
      _hasAnswered = false;
      _selectedAnswer = null;
    });
  }

  void _handleAnswer(String option) {
    if (_hasAnswered) return;

    final currentQuestion = _questions[_currentIndex];
    final bool isCorrect = option == currentQuestion.correctSign;

    setState(() {
      _selectedAnswer = option;
      _isCorrect = isCorrect;
      _hasAnswered = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _hasAnswered = false;
        _selectedAnswer = null;
      });
    } else {
      // Test bittiğinde başarı oranını UserStatsProvider'a kaydet
      Provider.of<UserStatsProvider>(context, listen: false).updatePracticeSuccess(_score, _questions.length);
      _showResults();
    }
  }

  void _showResults() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final percentage = (_score / _questions.length * 100).round();
        final bool passed = percentage >= 70;
        
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text('Test Tamamlandı!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '%$percentage',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: passed ? AppTheme.successGreen : AppTheme.errorRed,
                    ),
                  ),
                ],
              ),
              Text(
                '$_score Doğru / ${_questions.length} Soru',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textGray),
              ),
              const SizedBox(height: 12),
              Text(
                passed ? 'Harika bir performans! Yeni işaretler öğrenmeye devam et.' : 'Daha fazla pratik yaparak bu oranı yükseltebilirsin!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Bottom sheet kapat
                        context.go('/practice-test'); // Kategori seçimine dön
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Kategoriler', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _generateQuiz();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Tekrar Çöz', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.isGuest) {
      return const RestrictedAccessView(
        title: 'Alıştırma Yap',
        description: 'Alıştırmalara katılmak ve başarı oranınızı takip etmek için lütfen giriş yapın veya kayıt olun.',
      );
    }

    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Pratik Testi', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold)),
        leading: IconButton(
          onPressed: () => context.go('/practice-test'),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // İlerleme Çubuğu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (_currentIndex) / _questions.length,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentIndex + 1}/${_questions.length}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ],
              ),
            ),
            
            // GIF Görüntüleme
            Expanded(
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      question.gifPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

            // Şıklar (4 Buton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: question.options.map((option) {
                  bool isSelected = _selectedAnswer == option;
                  bool isCorrectAnswer = option == question.correctSign;
                  
                  Color btnColor = Theme.of(context).colorScheme.surface;
                  Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
                  Color borderColor = Colors.grey.withOpacity(0.3);

                  if (_hasAnswered) {
                    if (isCorrectAnswer) {
                      btnColor = AppTheme.successGreen.withOpacity(0.1);
                      borderColor = AppTheme.successGreen;
                      textColor = AppTheme.successGreen;
                    } else if (isSelected && !isCorrectAnswer) {
                      btnColor = AppTheme.errorRed.withOpacity(0.1);
                      borderColor = AppTheme.errorRed;
                      textColor = AppTheme.errorRed;
                    } else {
                      btnColor = Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100;
                      borderColor = Colors.transparent;
                      textColor = Colors.grey.shade400;
                    }
                  } else if (isSelected) {
                    btnColor = AppTheme.primaryBlue.withOpacity(0.1);
                    borderColor = AppTheme.primaryBlue;
                  }

                  return GestureDetector(
                    onTap: () => _handleAnswer(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: btnColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Text(
                        option,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Kontrol Et / Devam Et Barı
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _hasAnswered ? 100 : 0,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _isCorrect ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
                border: Border(top: BorderSide(color: _isCorrect ? AppTheme.successGreen : AppTheme.errorRed, width: 2)),
              ),
              child: _hasAnswered ? Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isCorrect ? Icons.check_rounded : Icons.close_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isCorrect ? 'Harika!' : 'Doğrusu:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                        ),
                        if (!_isCorrect)
                          Text(
                            question.correctSign,
                            style: TextStyle(fontSize: 14, color: AppTheme.errorRed.withOpacity(0.8)),
                          ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCorrect ? AppTheme.successGreen : AppTheme.errorRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Devam Et', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
