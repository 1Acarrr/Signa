import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_fullNameController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      _showError('Lütfen tüm alanları doldurun.');
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Şifreler eşleşmiyor!');
      return;
    }

    if (!_agreedToTerms) {
      _showError('Lütfen şartları ve koşulları kabul edin.');
      return;
    }

    try {
      await authProvider.signup(
        _emailController.text.trim(), 
        _passwordController.text, 
        _fullNameController.text.trim()
      );
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
                'Kayıt Ol',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Yeni bir hesap oluşturarak aramıza katılın.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textDark.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              
              // Profil İkonu
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_add_outlined, size: 40, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel('Ad Soyad'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _fullNameController,
                hint: 'Adınız ve soyadınız',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),

              _buildLabel('E-posta'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _emailController,
                hint: 'E-posta adresiniz',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _buildLabel('Şifre'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _passwordController,
                hint: 'Şifre oluşturun',
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
              const SizedBox(height: 20),

              _buildLabel('Şifreyi Onayla'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _confirmPasswordController,
                hint: 'Şifreyi tekrar girin',
                icon: Icons.lock_reset_rounded,
                obscureText: !_isConfirmPasswordVisible,
                suffix: IconButton(
                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppTheme.textDark.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      activeColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w600),
                          children: [
                            const TextSpan(text: 'Hüküm ve Koşulları ile '),
                            TextSpan(
                              text: 'Gizlilik Politikası',
                              style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w800),
                            ),
                            const TextSpan(text: ' kabul ediyorum.'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: authProvider.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Kayıt Ol',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Zaten hesabınız var mı? ',
                    style: TextStyle(color: AppTheme.textDark.withOpacity(0.6), fontWeight: FontWeight.w700),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Giriş Yap',
                      style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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
        hintStyle: TextStyle(color: AppTheme.textDark.withOpacity(0.3), fontWeight: FontWeight.w600),
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
