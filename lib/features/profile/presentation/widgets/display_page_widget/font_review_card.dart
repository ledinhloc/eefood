import 'package:eefood/features/profile/presentation/provider/settings_state.dart';
import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class FontReviewCard extends StatelessWidget {
  final SettingsState state;
  const FontReviewCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Scale theo setting hiện tại để preview
    final previewSize = switch (state.fontSize) {
      AppFontSize.small => 13.0,
      AppFontSize.medium => 15.0,
      AppFontSize.large => 18.0,
      AppFontSize.extraLarge => 21.0,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_fields_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Preview',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: previewSize,
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
            child: Text(l10n.fontPreview),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.fontSizeHint,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
