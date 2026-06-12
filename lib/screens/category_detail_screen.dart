import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/sign_data.dart';
import 'camera_practice_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryDetailScreen({Key? key, required this.category}) : super(key: key);

  void _showSignDetail(BuildContext context, String sign) {
    final categoryId = category['id'];
    final filename = SignData.getFilename(sign);
    final gifPath = 'assets/gifs/$categoryId/$filename.gif';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              sign,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${category['title']} Kategorisi',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey[200]!),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    gifPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'GIF henüz eklenmemiş',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (category['id'] == 'harfler')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context); // Kapat modali
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CameraPracticeScreen(
                                targetSign: sign,
                                gifPath: gifPath,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.videocam),
                        label: const Text('Kamerayla Dene'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (category['id'] == 'harfler') const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signs = SignData.categorySigns[category['id']] ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: category['color'] as Color,
        elevation: 0,
        title: Text(category['title'] as String),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${category['title']} İşaretleri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bu kategoride ${signs.length} adet işaret bulunuyor.',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: signs.length,
                itemBuilder: (context, index) {
                  final sign = signs[index];
                  return GestureDetector(
                    onTap: () => _showSignDetail(context, sign),
                    child: Container(
                      decoration: BoxDecoration(
                        color: (category['color'] as Color).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (category['color'] as Color).withOpacity(0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          sign,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: category['color'] as Color,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
