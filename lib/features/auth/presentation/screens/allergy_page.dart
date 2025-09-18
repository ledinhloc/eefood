import 'package:eefood/features/auth/presentation/widgets/preference_grid_page.dart';
import 'package:flutter/material.dart';

class AllergyPage extends StatelessWidget {
  final Set<String> selectedCuisines;
  final Function(Set<String>) onSelectionComplete;
  
  const AllergyPage({
    super.key,
    required this.selectedCuisines,
    required this.onSelectionComplete,
  });

  @override
  Widget build(BuildContext context) {
    final allergies = [
      {"name": "Đậu phộng", "icon": "🥜"},
      {"name": "Hạt", "icon": "🌰"},
      {"name": "Sữa bò", "icon": "🥛"},
      {"name": "Trứng gà", "icon": "🥚"},
      {"name": "Lúa mì", "icon": "🌾"},
      {"name": "Đậu nành", "icon": "🫘"},
      {"name": "Cá", "icon": "🐟"},
      {"name": "Tôm cua", "icon": "🦐"},
      {"name": "Vừng/Mè", "icon": "⚪"},
      {"name": "Mắm tôm", "icon": "🟣"},
      {"name": "Ốc, nghêu, sò", "icon": "🐚"},
    ];

    return PreferenceGridPage(
      title: "Chọn nguyên liệu bạn bị dị ứng",
      description: "Liệt kê các thành phần có thể gây dị ứng.\nBạn có thể bỏ qua nếu không có.",
      items: allergies,
      initialSelection: {},
      onSelectionComplete: onSelectionComplete,
      onSkip: () {
        onSelectionComplete({});
      },
    );
  }
}