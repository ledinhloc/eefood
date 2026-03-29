import 'package:eefood/features/nutrition/presentation/screens/nutrition_camera_screen.dart';
import 'package:eefood/features/nutrition/presentation/screens/qr_scanner_screen.dart';
import 'package:eefood/features/nutrition/presentation/widgets/choice_card.dart';
import 'package:eefood/features/post/presentation/widgets/post/image_search/image_search_page.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ImageChoiceScreen extends StatefulWidget {
  const ImageChoiceScreen({super.key});

  @override
  State<ImageChoiceScreen> createState() => _ImageChoiceScreenState();
}

class _ImageChoiceScreenState extends State<ImageChoiceScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideCard1;
  late Animation<Offset> _slideCard2;
  late Animation<Offset> _slideCard3;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _slideCard1 = Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    _slideCard2 = Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _slideCard3 = Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F0F0F) : Colors.white;
    final cardBg1 = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFFF8F3);
    final cardBg2 = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
    final cardBg3 = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF3F8FF);
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark
        ? Colors.white60
        : const Color(0xFF1A1A1A).withOpacity(0.55);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeTransition(
          opacity: _fadeAnim,
          child: Text(
            l10n.optionTitle,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              letterSpacing: -0.3,
            ),
          ),
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _fadeAnim,
              child: Text(
                l10n.subOptionTitle,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 15,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card 1: Tìm kiếm
            SlideTransition(
              position: _slideCard1,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.2, 0.7),
                ),
                child: ChoiceCard(
                  title: l10n.lookUpTitle,
                  subtitle: l10n.lookUpSubtitle,
                  icon: Icons.image_search_rounded,
                  accentColor: const Color(0xFFFF6B00),
                  backgroundColor: cardBg1,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    _buildPageRoute(const ImageSearchScreen()),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card 2: Phân tích dinh dưỡng
            SlideTransition(
              position: _slideCard2,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.3, 0.8),
                ),
                child: ChoiceCard(
                  title: l10n.analyzeTitle,
                  subtitle: l10n.analyzeSubtitle,
                  icon: Icons.analytics_rounded,
                  accentColor: const Color(0xFF00C896),
                  backgroundColor: cardBg2,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    _buildPageRoute(const NutritionCameraScreen()),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Card 3: Quét mã QR
            SlideTransition(
              position: _slideCard3,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.4, 0.9),
                ),
                child: ChoiceCard(
                  title: l10n.qrTitle,
                  subtitle: l10n.qrSubtitle,
                  icon: Icons.qr_code_2_outlined,
                  accentColor: const Color(0xFF3B82F6),
                  backgroundColor: cardBg3,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    _buildPageRoute(const QrScannerScreen()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PageRouteBuilder _buildPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, animation, __) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
