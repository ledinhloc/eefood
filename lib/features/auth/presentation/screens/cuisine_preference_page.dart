import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/features/auth/presentation/widgets/preference_grid_page.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CuisinePreferencePage extends StatelessWidget {
  final Function(Set<String>) onSelectionComplete;

  const CuisinePreferencePage({super.key, required this.onSelectionComplete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PreferenceGridPage(
      title: l10n.cuisineTitle, // key: cuisineTitle
      description: l10n.cuisineDesc, // key: cuisineDesc
      items: AppConstants.cuisines,
      initialSelection: {},
      onSelectionComplete: onSelectionComplete,
      onSkip: () {
        onSelectionComplete({});
      },
    );
  }
}
