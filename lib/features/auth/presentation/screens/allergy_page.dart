import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/features/auth/presentation/widgets/preference_grid_page.dart';
import 'package:eefood/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return PreferenceGridPage(
      title: l10n.allergyTitle, // key: allergyTitle
      description: l10n.allergyDesc, // key: allergyDesc
      items: AppConstants.allergies,
      initialSelection: {},
      onSelectionComplete: onSelectionComplete,
      onSkip: () {
        onSelectionComplete({});
      },
    );
  }
}
