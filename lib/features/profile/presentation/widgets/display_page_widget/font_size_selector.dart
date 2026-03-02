import 'package:eefood/features/app_settings/collections/app_settings.dart';
import 'package:eefood/features/profile/presentation/provider/settings_cubit.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FontSizeSelector extends StatelessWidget {
  final AppFontSize currentSize;
  const FontSizeSelector({super.key, required this.currentSize});

  static const _sizes = [
    AppFontSize.small,
    AppFontSize.medium,
    AppFontSize.large,
    AppFontSize.extraLarge,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final primary = theme.colorScheme.primary;

    final labels = [
      l10n.fontSmall,
      l10n.fontMedium,
      l10n.fontLarge,
      l10n.fontExtraLarge,
    ];
    final selectedIndex = _sizes.indexOf(currentSize);

    return Column(
      children: [
        // Slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            activeTrackColor: primary,
            inactiveTrackColor: primary.withOpacity(0.15),
            thumbColor: primary,
            overlayColor: primary.withOpacity(0.12),
          ),
          child: Slider(
            value: selectedIndex.toDouble(),
            min: 0,
            max: 3,
            divisions: 3,
            onChanged: (value) {
              context.read<SettingsCubit>().changeFontSize(
                _sizes[value.round()],
              );
            },
          ),
        ),

        const SizedBox(height: 4),

        // Labels dưới slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labels.asMap().entries.map((e) {
              final isActive = e.key == selectedIndex;
              return Text(
                e.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive
                      ? primary
                      : theme.colorScheme.onSurface.withOpacity(0.4),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // Chips lựa chọn nhanh
        Row(
          children: _sizes.asMap().entries.map((e) {
            final size = e.value;
            final label = labels[e.key];
            final isSelected = currentSize == size;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: e.key < 3 ? 8 : 0),
                child: GestureDetector(
                  onTap: () =>
                      context.read<SettingsCubit>().changeFontSize(size),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primary
                          : theme.colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
