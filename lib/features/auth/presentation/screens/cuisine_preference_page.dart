import 'package:eefood/core/constants/app_constants.dart';
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

    return PreferenceGridPage(
      title: "Chọn món ăn yêu thích của bạn",
      description: "Chọn món ăn ưa thích của bạn để có những gợi ý tốt hơn hoặc bạn có thể bỏ qua.",
      items: AppConstants.cuisines,
      initialSelection: {},
      onSelectionComplete: onSelectionComplete,
      onSkip: () {
        onSelectionComplete({});
      },
    );
  }
}