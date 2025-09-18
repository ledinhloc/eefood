import 'package:eefood/features/auth/presentation/widgets/preference_grid_page.dart';
import 'package:flutter/material.dart';

class CuisinePreferencePage extends StatelessWidget {
  final Function(Set<String>) onSelectionComplete;
  
  const CuisinePreferencePage({
    super.key,
    required this.onSelectionComplete,
  });

  @override
  Widget build(BuildContext context) {
    final cuisines = [
      {"name": "Gỏi/Salad", "icon": "🥗"},
      {"name": "Trứng", "icon": "🍳"},
      {"name": "Canh/Súp", "icon": "🍲"},
      {"name": "Thịt heo/bò", "icon": "🍖"},
      {"name": "Gà", "icon": "🍗"},
      {"name": "Hải sản", "icon": "🦐"},
      {"name": "Bánh mì kẹp", "icon": "🥪"},
      {"name": "Bánh xèo", "icon": "🥞"},
      {"name": "Phở", "icon": "🍜"},
      {"name": "Bún chả", "icon": "🍢"},
      {"name": "Cơm tấm", "icon": "🍚"},
      {"name": "Pizza", "icon": "🍕"},
      {"name": "Sushi", "icon": "🍣"},
    ];

    return PreferenceGridPage(
      title: "Chọn món ăn yêu thích của bạn",
      description: "Chọn món ăn ưa thích của bạn để có những gợi ý tốt hơn hoặc bạn có thể bỏ qua.",
      items: cuisines,
      initialSelection: {},
      onSelectionComplete: onSelectionComplete,
      onSkip: () {
        onSelectionComplete({});
      },
    );
  }
}