import 'package:eefood/features/app_settings/collections/app_settings.dart';
import 'package:eefood/features/profile/presentation/provider/settings_cubit.dart';
import 'package:eefood/features/profile/presentation/widgets/display_page_widget/theme_card.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeSelector extends StatelessWidget {
  final AppThemeMode currentTheme;
  const ThemeSelector({super.key, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final options = [
      (AppThemeMode.light, Icons.wb_sunny_rounded, l10n.themeLight),
      (AppThemeMode.dark, Icons.nightlight_round, l10n.themeDark),
      (AppThemeMode.system, Icons.settings_suggest_rounded, l10n.themeSystem),
    ];

    return Row(
      children: options.asMap().entries.map((entry) {
        final (mode, icon, label) = entry.value;
        final isSelected = currentTheme == mode;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.key < options.length - 1 ? 10 : 0,
            ),
            child: ThemeCard(
              mode: mode,
              icon: icon,
              label: label,
              isSelected: isSelected,
              onTap: () => context.read<SettingsCubit>().changeThemeMode(mode),
            ),
          ),
        );
      }).toList(),
    );
  }
}
