import 'package:flutter/material.dart';

/// Hàm helper mở CustomBottomSheet
Future<void> showCustomBottomSheet(
    BuildContext context,
    List<BottomSheetOption> options,
    ) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => CustomBottomSheet(options: options),
  );
}

/// Model đại diện cho một lựa chọn trong BottomSheet
class BottomSheetOption {
  final Widget icon;
  final String title;
  final VoidCallback onTap;

  BottomSheetOption({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}

class CustomBottomSheet extends StatelessWidget {
  final List<BottomSheetOption> options;
  const CustomBottomSheet({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title (optional)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Chọn thao tác",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 20, thickness: 1),

            // Options List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: options.asMap().entries.map((entry) {
                  final index = entry.key;
                  final opt = entry.value;
                  final isLast = index == options.length - 1;

                  return _buildOptionTile(context, opt, isLast);
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context,
      BottomSheetOption option,
      bool isLast,
      ) {
    // Xác định màu theo icon
    Color accentColor = _getAccentColor(option.icon);

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            option.onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconTheme(
                    data: IconThemeData(color: accentColor, size: 22),
                    child: option.icon,
                  ),
                ),
                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    option.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper để lấy màu accent dựa vào icon
  Color _getAccentColor(Widget iconWidget) {
    if (iconWidget is Icon) {
      final color = iconWidget.color;
      if (color == Colors.blue) return const Color(0xFF4ECDC4);
      if (color == Colors.red) return const Color(0xFFFF6B6B);
      if (color == Colors.green) return const Color(0xFF66BB6A);
      if (color == Colors.orange) return const Color(0xFFFFBE0B);
      if (color == Colors.purple) return const Color(0xFF9B59B6);
    }
    // Default color cho food theme
    return const Color(0xFFFF6B6B);
  }
}