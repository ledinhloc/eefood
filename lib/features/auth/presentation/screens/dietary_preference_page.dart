import 'package:eefood/app_routes.dart';
import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/auth/domain/usecases/auth_usecases.dart';
import 'package:eefood/features/auth/presentation/widgets/preference_grid_page.dart';
import 'package:eefood/features/profile/domain/usecases/profile_usecase.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../data/models/user_model.dart';

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

  Future<void> _savePreferences(
    BuildContext context,
    Set<String> selectedDiets,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final User? user = await _getCurrentUser();
    final request = UserModel(
      id: user!.id,
      username: user.username,
      email: user.email,
      role: user.role,
      provider: user.provider,
      eatingPreferences: selectedCuisines.toList(),
      allergies: selectedAllergies.toList(),
      dietaryPreferences: selectedDiets.toList(),
    );

    final result = await _updateProfile(request);
    if (result.isSuccess) {
      showCustomSnackBar(context, l10n.saveSuccess); // key: saveSuccess
      onComplete();
    } else {
      showCustomSnackBar(
        context,
        l10n.saveFailed,
        isError: true,
      ); // key: saveFailed
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PreferenceGridPage(
      title: l10n.dietaryTitle, // key: dietaryTitle
      description: l10n.dietaryDesc, // key: dietaryDesc
      items: AppConstants.diets,
      initialSelection: {},
      onSelectionComplete: (selectedDiets) async {
        await _savePreferences(context, selectedDiets);
      },
      onSkip: () {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      },
      continueButtonText: l10n.finish, // key: finish
    );
  }
}
