import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/enum/subtitle_language.dart';
import '../provider/subtitle_cubit.dart';
import '../provider/subtitle_state.dart';

class LiveSubtitleLanguageSelector extends StatelessWidget {
  final SubtitleState state;
  final String tooltip;

  const LiveSubtitleLanguageSelector({
    super.key,
    required this.state,
    this.tooltip = 'Chon phu de',
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SubtitleLanguage>(
      tooltip: tooltip,
      onSelected: (language) {
        context.read<SubtitleCubit>().changeSubtitleLanguage(language);
      },
      color: Colors.black.withValues(alpha: 0.88),
      initialValue: state.selectedSubtitleLanguage,
      itemBuilder: (context) {
        return SubtitleLanguage.values.map((language) {
          final isSelected = language == state.selectedSubtitleLanguage;
          return PopupMenuItem<SubtitleLanguage>(
            value: language,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    language.label,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check, color: Colors.white, size: 18),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.settings, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              state.selectedSubtitleLanguage.shortLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              state.selectedSubtitleLanguage == SubtitleLanguage.off
                  ? Icons.subtitles_off
                  : state.isSubtitleConnected
                      ? Icons.keyboard_arrow_down
                      : Icons.wifi_off_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
