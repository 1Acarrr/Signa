import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/user_stats_provider.dart';
import '../navigation/router.dart';

import 'widgets/restricted_access_view.dart';
import 'widgets/edit_profile_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final statsProvider = Provider.of<UserStatsProvider>(context);
    
    if (authProvider.isGuest) {
      return const RestrictedAccessView(
        title: 'Profil',
        description: 'Profilinizi görüntülemek ve istatistiklerinizi kaydetmek için lütfen giriş yapın veya kayıt olun.',
      );
    }

    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text('Profil'),
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1E40AF),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: user?.photoURL != null
                          ? (user!.photoURL!.startsWith('http')
                              ? Image.network(user.photoURL!, fit: BoxFit.contain)
                              : Image.asset(user.photoURL!, fit: BoxFit.contain, cacheWidth: 300))
                          : (user?.displayName != null && user!.displayName!.isNotEmpty)
                              ? Center(
                                  child: Text(
                                    user.displayName!.trim().split(' ').map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').take(2).join(),
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.displayName ?? 'Kullanıcı',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const EditProfileDialog(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2563EB),
                    ),
                    child: const Text('Profili Düzenle'),
                  ),
                ],
              ),
            ),
            
            // Gerçek İstatistikler
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatTile('${statsProvider.totalTranslations}', 'Toplam\nÇeviri'),
                  _buildStatTile('${statsProvider.learnedSigns}', 'Öğrenilen\nİşaret'),
                  _buildStatTile('%${statsProvider.practiceSuccessRate}', 'Başarı\nOranı'),
                ],
              ),
            ),
            
            const Divider(),
            
            // Hakkında ve Menüler (Güncellendi)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kişisel Bilgiler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingTile(
                    'Uygulama Sürümü',
                    'SIGNA v1.0.1 - En Güncel',
                    const Icon(Icons.verified_outlined),
                    () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'SIGNA',
                        applicationVersion: '1.0.1',
                        applicationIcon: const Icon(Icons.info, size: 48, color: Color(0xFF2563EB)),
                        children: const [
                          Text('SIGNA - İşaret Dili Öğrenme ve Çeviri Uygulaması\n\nTüm hakları saklıdır.'),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    'Kullanım Koşulları',
                    'Şartlar ve Koşullarımızı görüntüleyin',
                    const Icon(Icons.description_outlined),
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
                  _buildSettingTile(
                    'Gizlilik Politikası',
                    'Verilerinizin güvenliği hakkında',
                    const Icon(Icons.privacy_tip_outlined),
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
                  const SizedBox(height: 12),
                  _buildSettingTile(
                    'Destek & İletişim',
                    'Bize ulaşın: support@signa.com',
                    const Icon(Icons.mail_outline),
                    () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('İletişim'),
                          content: const Text('Soru, görüş ve destek talepleriniz için bize e-posta yoluyla ulaşabilirsiniz:\n\nsupport@signa.com'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Kapat')),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // Çıkış Yap Butonu
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        title: const Text('Çıkış Yap'),
                        content: const Text('Hesabınızdan çıkış yapmak istediğinize emin misiniz?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('İptal', style: TextStyle(color: Colors.grey)),
                          ),
                          TextButton(
                            onPressed: () async {
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              Navigator.pop(context); // Diyaloğu kapat
                              await authProvider.logout(); // Çıkış işlemini başlat
                              appRouter.go('/welcome'); // Karşılama ekranına dön
                            },
                            child: const Text(
                              'Çıkış Yap',
                              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Çıkış Yap'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: Color(0xFFEF4444),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    Icon icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withOpacity(0.08),
              ),
              child: Icon(
                icon.icon,
                color: const Color(0xFF2563EB),
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}

