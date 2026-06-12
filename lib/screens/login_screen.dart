import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Lütfen tüm alanları doldurun.');
      return;
    }

    try {
      await authProvider.login(_emailController.text.trim(), _passwordController.text);
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.signInWithGoogle();
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString());
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(

        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () {
            if (authProvider.isGuest) {
              context.go('/home');
            } else {
              context.go('/welcome');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textDark, size: 22),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Tekrar\nHoş Geldiniz!',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Devam etmek için lütfen giriş yapın.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textDark.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              
              // Email
              _buildLabel('E-posta'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _emailController,
                hint: 'E-posta adresinizi girin',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              
              // Password
              _buildLabel('Şifre'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _passwordController,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                obscureText: !_isPasswordVisible,
                suffix: IconButton(
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textDark.withOpacity(0.5),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Şifremi Unuttum?',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Giriş Yap Butonu
              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          children: const [
                            SizedBox(width: 32),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Giriş Yap',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 26),
                          ],
                        ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.withOpacity(0.2), thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'veya devam et',
                      style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.withOpacity(0.2), thickness: 1)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Google Butonu
              SizedBox(
                width: double.infinity,
                height: 62,
                child: OutlinedButton(
                  onPressed: authProvider.isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade200, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    backgroundColor: Colors.white,
                  ),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                        children: [
                          const TextSpan(text: 'G', style: TextStyle(color: Color(0xFF4285F4))),
                          const TextSpan(text: 'o', style: TextStyle(color: Color(0xFFEA4335))),
                          const TextSpan(text: 'o', style: TextStyle(color: Color(0xFFFBBC05))),
                          const TextSpan(text: 'g', style: TextStyle(color: Color(0xFF4285F4))),
                          const TextSpan(text: 'l', style: TextStyle(color: Color(0xFF34A853))),
                          const TextSpan(text: 'e', style: TextStyle(color: Color(0xFFEA4335))),
                          TextSpan(
                            text: ' ile Giriş Yap',
                            style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Hesabınız yok mu? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/signup'),
                    child: Text(
                      'Kayıt Olun',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationThickness: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark, fontSize: 15),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textDark.withOpacity(0.4), fontWeight: FontWeight.w600),
        prefixIcon: Icon(icon, color: AppTheme.primaryBlue, size: 22),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade100)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade100)),
      ),
    );
  }
}
