import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color scaffoldBg = isDark
        ? const Color(0xFF1A1A1A)
        : const Color(0xFFFFF8F3); // trắng ngà ấm

    final Color cardBg = isDark
        ? const Color(0xFF242424) // xám than nhẹ, không quá tối
        : Colors.white;

    final Color accentColor = isDark
        ? const Color(0xFFFFAB6B) // cam đào nhạt hơn cho nền tối
        : const Color(0xFFFF7A2F); // cam đào tươi

    final Color accentBgLight = isDark
        ? const Color(0xFF2E2218) // nền cam siêu nhạt trên dark
        : const Color(0xFFFFF3EB); // nền cam siêu nhạt trên light

    final Color titleText = isDark
        ? const Color(0xFFF5F0EB) // trắng ngà ấm
        : const Color(0xFF2D1F0F); // nâu đậm (không dùng đen thuần)

    final Color bodyText = isDark
        ? const Color(0xFFBBB0A8) // xám ấm vừa
        : const Color(0xFF6B5B4E); // nâu xám trung tính

    final Color dividerColor = isDark
        ? Colors.white.withOpacity(0.06)
        : const Color(0xFFEEE0D5);

    final Color shadowColor = isDark
        ? Colors.black.withOpacity(0.35)
        : const Color(0xFFE8D5C4).withOpacity(0.6); // bóng cam nhạt

    final List<Color> bgGradient = isDark
        ? [const Color(0xFF221A14), const Color(0xFF1A1A1A)]
        : [const Color(0xFFFFEEDE), const Color(0xFFFFF8F3)];

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Điều khoản sử dụng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: titleText,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark
            ? const Color(0xFF1A1A1A)
            : const Color(0xFFFFF8F3),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: accentColor),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: bgGradient,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon nằm trong vòng tròn màu cam nhạt
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: accentBgLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      size: 40,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Điều khoản sử dụng',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: titleText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Ngày dạng pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accentBgLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Cập nhật: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            ...AppConstants.termsOfService.asMap().entries.map((entry) {
              final index = entry.key;
              final term = entry.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header mục: nền cam nhạt + số thứ tự
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                        decoration: BoxDecoration(
                          color: accentBgLight,
                          border: Border(
                            bottom: BorderSide(color: dividerColor, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: accentColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                term['title']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? accentColor
                                      : const Color(0xFF2D1F0F),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Nội dung mục
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                        child: Text(
                          term['content']!,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.65,
                            color: bodyText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentBgLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? accentColor.withOpacity(0.25)
                      : const Color(0xFFFFCCA3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_outlined, color: accentColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bằng việc sử dụng ứng dụng EEFood, bạn đồng ý với tất cả các điều khoản trên.',
                      style: TextStyle(
                        fontSize: 13,
                        color: bodyText,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
