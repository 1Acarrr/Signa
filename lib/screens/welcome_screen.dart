import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Top illustration area
              Container(
                height: MediaQuery.of(context).size.height * 0.38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9), // Softer light gray
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 170,
                            height: 170,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.waving_hand_rounded,
                              size: 80,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Text Content - Increased Clarity
              Text(
                'SİGNA\'ya\nHoş Geldiniz',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w800, // Extra Bold for impact
                  height: 1.1,
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'İşaret dili kullananlar ve bilmeyenler arasında kesintisiz iletişimi keşfedin.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textDark.withOpacity(0.7), // Darker for better contrast
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Buttons - More Defined
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 2,
                ),
                child: const Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.go('/signup'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  side: const BorderSide(color: AppTheme.primaryBlue, width: 2), // Thicker border
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text(
                  'Kayıt Ol',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 28),
              
              // Guest link - Bolder
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Misafir durumunu aktif et
                    Provider.of<AuthProvider>(context, listen: false).loginAsGuest();
                    // Ana sayfaya git
                    context.go('/home');
                  },
                  child: Text(
                    'Misafir Olarak Devam Et',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700, // Bold
                      letterSpacing: 0.5,
                      decoration: TextDecoration.underline,
                      decorationThickness: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
