import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../config/theme.dart';
import 'home_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'widgets/change_username_dialog.dart';
import 'widgets/change_password_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Ayarlar',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Görünüm'),
          _buildSwitchTile(
            'Karanlık Mod',
            Icons.dark_mode_outlined,
            themeProvider.isDarkMode,
            (val) => themeProvider.toggleTheme(val),
          ),
          const SizedBox(height: 24),
          
          if (!authProvider.isGuest) ...[
            _buildSectionHeader('Hesap'),
            _buildListTile(
              'Kullanıcı Adı Değiştir',
              Icons.person_outline,
              () => _showUpdateNameDialog(context, authProvider),
            ),
            const SizedBox(height: 12),
            _buildListTile(
              'Şifre Değiştir',
              Icons.lock_outline,
              () => _showUpdatePasswordDialog(context, authProvider),
            ),
            const SizedBox(height: 24),
          ],
          
          _buildSectionHeader('Diğer'),
          _buildListTile(
            'Uygulama Sürümü',
            Icons.info_outline,
            () {
              showAboutDialog(
                context: context,
                applicationName: 'SIGNA',
                applicationVersion: '1.0.1',
                applicationIcon: const Icon(Icons.info, size: 48, color: AppTheme.primaryBlue),
                children: const [
                  Text('SIGNA - İşaret Dili Öğrenme ve Çeviri Uygulaması\n\nTüm hakları saklıdır.'),
                ],
              );
            },
            trailingText: 'v1.0.1',
          ),
          const SizedBox(height: 12),
          _buildListTile(
            'Kullanım Koşulları',
            Icons.description_outlined,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kullanım Koşulları'),
                  content: const SingleChildScrollView(
                    child: Text('Uygulamayı kullanarak tüm şartlar ve koşulları kabul etmiş sayılırsınız. Kullanıcı verileri sadece yerel cihazınızda ve onayınızla bulutta işlenir.'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildListTile(
            'Gizlilik Politikası',
            Icons.privacy_tip_outlined,
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Gizlilik Politikası'),
                  content: const SingleChildScrollView(
                    child: Text('Kişisel verileriniz gizlilik standartlarına uygun olarak korunmaktadır. Kamera görüntüleriniz sadece anlık çeviri için kullanılır, kaydedilmez.'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Çıkış Yap'),
                    content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('İptal')),
                      ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await authProvider.logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                        child: const Text('Çıkış Yap'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout, color: AppTheme.errorRed),
              label: const Text('Çıkış Yap', style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorRed),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: 2,
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/learn-signs');
          if (index == 2) return;
          if (index == 3) context.go('/profile');
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textGray,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primaryBlue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap, {String? trailingText}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppTheme.primaryBlue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: trailingText != null 
        ? Text(trailingText, style: const TextStyle(color: AppTheme.textGray, fontWeight: FontWeight.w500))
        : const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textGray),
      onTap: onTap,
    );
  }

  void _showUpdateNameDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => const ChangeUsernameDialog(),
    );
  }

  void _showUpdatePasswordDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}
