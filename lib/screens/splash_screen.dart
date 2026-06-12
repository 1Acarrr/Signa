import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Softer Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF3B82F6), // Soft Sky Blue
                  Color(0xFF1D4ED8), // Soft Royal Blue
                ],
              ),
            ),
          ),
          
          // 2. Very Faint Background Silhouettes
          _buildBackgroundHand(top: 120, right: -30, rotation: 0.3, size: 240, opacity: 0.03),
          _buildBackgroundHand(bottom: 280, left: -50, rotation: -0.2, size: 260, opacity: 0.03),
          
          // 3. Ultra Soft Wave Pattern
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 220,
              child: CustomPaint(
                painter: WavePainter(
                  color1: Colors.white.withOpacity(0.08),
                  color2: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
          ),
          
          // 4. Main Content
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Container with a subtle shadow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.back_hand_rounded, color: Colors.white, size: 80),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // App Name
                  const Text(
                    'Signa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Tagline
                  const Text(
                    'İşaret diliyle iletişimi\nkolaylaştırıyoruz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // 5. Progress Bar and Loading Text
          Positioned(
            bottom: 60,
            left: 60,
            right: 60,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Yükleniyor...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundHand({double? top, double? bottom, double? left, double? right, required double rotation, required double size, double opacity = 0.05}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity,
        child: Transform.rotate(
          angle: rotation,
          child: Icon(Icons.front_hand_rounded, size: size, color: Colors.white),
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color1;
  final Color color2;

  WavePainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, size.height * 0.7);
    path1.quadraticBezierTo(size.width * 0.25, size.height * 0.5, size.width * 0.5, size.height * 0.7);
    path1.quadraticBezierTo(size.width * 0.75, size.height * 0.9, size.width, size.height * 0.7);
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();
    canvas.drawPath(path1, paint);

    final paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    path2.quadraticBezierTo(size.width * 0.25, size.height * 0.9, size.width * 0.5, size.height * 0.7);
    path2.quadraticBezierTo(size.width * 0.75, size.height * 0.5, size.width, size.height * 0.8);
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
