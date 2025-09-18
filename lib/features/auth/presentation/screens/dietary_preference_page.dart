import 'package:eefood/app_routes.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/widgets/preference_grid_page.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:flutter/material.dart';


class DietaryPreferencePage extends StatelessWidget {
  final Set<String> selectedCuisines;
  final Set<String> selectedAllergies;
  final Function() onComplete;
  final UpdateProfile _updateProfile = getIt<UpdateProfile>();
  final GetCurrentUser _getCurrentUser = getIt<GetCurrentUser>();

  
  DietaryPreferencePage({
    super.key,
    required this.selectedCuisines,
    required this.selectedAllergies,
    required this.onComplete,
  });

  Future<void> _savePreferences(BuildContext context, Set<String> selectedDiets) async {
    final User? user = await _getCurrentUser();
    final request = UserModel(
      id: user!.id,
      username: user.username,
      email: user.email,
      eatingPreferences: selectedCuisines.toList(),
      allergies: selectedAllergies.toList(),
      dietaryPreferences: selectedDiets.toList(),
    );

    final result = await _updateProfile(request);
    if (result.isSuccess) {
      showCustomSnackBar(context, 'Đã lưu thành công');
      onComplete();
    }else{
      showCustomSnackBar(context, 'Lưu thất bại!', isError: true);
    }
  }
  @override
  Widget build(BuildContext context) {
    final diets = [
      {"name": "Ăn chay", "icon": "🥦"},
      {"name": "Thuần chay", "icon": "🌱"},
      {"name": "Ăn cá", "icon": "🐟"},
      {"name": "Không gluten", "icon": "🚫🌾"},
      {"name": "Ít carb", "icon": "🥩"},
      {"name": "Paleo", "icon": "🍖"},
      {"name": "Halal", "icon": "🕌"},
      {"name": "Kosher", "icon": "✡️"},
      {"name": "Không đường", "icon": "🍬"},
      {"name": "Thấp natri", "icon": "🧂"},
      {"name": "Không sữa", "icon": "🥛"},
      {"name": "Eat Clean", "icon": "🥗"},
    ];

    return PreferenceGridPage(
      title: "Chọn chế độ ăn uống ưa thích của bạn",
      description: "Chọn chế độ ăn uống mà bạn đang dùng.\nBạn có thể bỏ qua bước này.",
      items: diets,
      initialSelection: {},
      onSelectionComplete: (selectedDiets) async{
        await _savePreferences(context, selectedDiets);
      },
      onSkip: () {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      },
      continueButtonText: "Finish",
    );
  }
}