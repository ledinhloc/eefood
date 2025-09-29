import 'package:eefood/core/constants/app_constants.dart';
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

    return PreferenceGridPage(
      title: "Chọn nguyên liệu bạn bị dị ứng",
      description: "Liệt kê các thành phần có thể gây dị ứng.\nBạn có thể bỏ qua nếu không có.",
      items: AppConstants.allergies,
      initialSelection: {},
      onSelectionComplete: onSelectionComplete,
      onSkip: () {
        onSelectionComplete({});
      },
    );
  }
}