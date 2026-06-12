import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import '../navigation/router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const HomeHeader(),
                    const SizedBox(height: 24),
                    const HeroTranslateCard(),
                    const SizedBox(height: 28),
                    Text(
                      'Hızlı Erişim',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const QuickActionGrid(),
                    const SizedBox(height: 30),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) return;
          if (index == 1) context.go('/learn-signs');
          if (index == 2) context.go('/settings');
          if (index == 3) context.go('/profile');
        },
      ),
    );
  }
}

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final String displayName = authProvider.user?.displayName ?? '';
    final bool isGuest = authProvider.isGuest;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isGuest ? 'Merhaba' : 'Merhaba, $displayName',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Bugün ne öğrenmek istersin?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGray,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildCircularIcon(BuildContext context, IconData icon, {bool hasBadge = false}) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 22, color: Theme.of(context).textTheme.bodyLarge?.color),
          if (hasBadge)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HeroTranslateCard extends StatelessWidget {
  const HeroTranslateCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200, maxHeight: 240),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner marks for focus effect
          _buildCornerMark(top: 16, left: 16, isTop: true, isLeft: true),
          _buildCornerMark(top: 16, right: 16, isTop: true, isLeft: false),
          _buildCornerMark(bottom: 16, left: 16, isTop: false, isLeft: true),
          _buildCornerMark(bottom: 16, right: 16, isTop: false, isLeft: false),
          
          Padding(
            padding: const EdgeInsets.all(16), // Reduced padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.back_hand_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 16),
                const Text(
                  'İşareti Çevir',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 200,
                  child: Text(
                    'Kamerayı aç ve işaret dilini metne dönüştür',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.3),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.go('/sign-translation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBlue,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  icon: const Icon(Icons.videocam_rounded, size: 18),
                  label: const Text('Başlat', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // Ready indicator
          Positioned(
            bottom: 24,
            right: 24,
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Hazır',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Illustration placeholder
          Positioned(
            right: -10,
            top: 40,
            child: Icon(
              Icons.front_hand_rounded,
              size: 100,
              color: Colors.white.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerMark({double? top, double? bottom, double? left, double? right, required bool isTop, required bool isLeft}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 15,
        height: 15,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Colors.white54, width: 2) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Colors.white54, width: 2) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Colors.white54, width: 2) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Colors.white54, width: 2) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.9,
      children: [
        _buildActionCard(
          context,
          'Konuşmayı Yazıya Çevir',
          'Sesi anlık olarak metne dönüştür',
          'assets/images/speech_to_text.png',
          const Color(0xFF0EA5E9),
          '/speech-to-text',
        ),
        _buildActionCard(
          context,
          'Karşılıklı İletişim',
          'İki yönlü konuşma modu',
          'assets/images/mutual_communication.png',
          const Color(0xFF22C55E),
          '/mutual-communication',
        ),
        _buildActionCard(
          context,
          'İşaretleri Öğren',
          'Kategorize edilmiş kütüphane',
          'assets/images/learn_signs.png',
          const Color(0xFF8B5CF6),
          '/learn-signs',
        ),
        _buildActionCard(
          context,
          'Alıştırma Yap',
          'Kendini test et ve geliştir',
          'assets/images/practice_test.png',
          const Color(0xFFF97316),
          '/practice-test',
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String desc, String imagePath, Color shadowColor, String route) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: shadowColor.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color, height: 1.2),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textGray, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryStatsCard extends StatelessWidget {
  const SummaryStatsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _buildStatItem(context, Icons.bar_chart_rounded, '45', 'Toplam Çeviri'),
            _buildDivider(context),
            _buildStatItem(context, Icons.school_rounded, '12', 'Öğrenilen İşaret'),
            _buildDivider(context),
            _buildStatItem(context, Icons.stars_rounded, '%82', 'Başarı Oranı'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textGray),
            textAlign: TextAlign.center,
          ),
          const Text(
            'Bu hafta',
            style: TextStyle(fontSize: 9, color: AppTheme.textGray),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(width: 1, color: Theme.of(context).scaffoldBackgroundColor);
  }
}

class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9E7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFEF3C7), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.waving_hand_rounded, color: Color(0xFFD97706), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Son öğrendiğin işaret',
                  style: TextStyle(fontSize: 10, color: Color(0xFF92400E), fontWeight: FontWeight.w500),
                ),
                const Text(
                  'Teşekkürler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF78350F)),
                ),
                const Text(
                  'Günlük iletişim',
                  style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ElevatedButton.icon(
              onPressed: () => context.go('/learn-signs'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              icon: const Text('Devam Et', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              label: const Icon(Icons.arrow_forward_rounded, size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({Key? key, required this.selectedIndex, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    
    Widget profileIcon;
    if (authProvider.isGuest) {
      profileIcon = const Icon(Icons.person_rounded);
    } else {
      if (user?.photoURL != null) {
        final bool isNetworkUrl = user!.photoURL!.startsWith('http');
        profileIcon = ClipOval(
          child: isNetworkUrl
              ? Image.network(user.photoURL!, width: 24, height: 24, fit: BoxFit.contain)
              : Image.asset(user.photoURL!, width: 24, height: 24, fit: BoxFit.contain, cacheWidth: 72),
        );
      } else if (user?.displayName != null && user!.displayName!.isNotEmpty) {
        List<String> names = user.displayName!.trim().split(' ');
        String initials = '';
        if (names.isNotEmpty) {
          initials += names.first[0].toUpperCase();
          if (names.length > 1) {
            initials += names.last[0].toUpperCase();
          }
        }
        profileIcon = CircleAvatar(
          radius: 12,
          backgroundColor: AppTheme.primaryBlue,
          child: Text(
            initials,
            style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      } else {
        profileIcon = const Icon(Icons.person_rounded);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppTheme.primaryBlue,
          unselectedItemColor: AppTheme.textGray.withOpacity(0.5),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Ana Sayfa'),
            const BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: 'Öğren'),
            const BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Ayarlar'),
            BottomNavigationBarItem(icon: profileIcon, label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
