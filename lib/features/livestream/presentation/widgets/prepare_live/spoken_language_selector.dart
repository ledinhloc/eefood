import 'package:flutter/material.dart';

import '../../../domain/enum/subtitle_language.dart';

class SpokenLanguageSelector extends StatelessWidget {
  final SubtitleLanguage selectedLanguage;
  final ValueChanged<SubtitleLanguage> onChanged;

  const SpokenLanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.translate, color: Colors.white, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ngôn ngữ nói',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Dùng để nhận diện phụ đề',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          SegmentedButton<SubtitleLanguage>(
            segments: const [
              ButtonSegment(
                value: SubtitleLanguage.vi,
                label: Text('VI'),
              ),
              ButtonSegment(
                value: SubtitleLanguage.en,
                label: Text('EN'),
              ),
            ],
            selected: {selectedLanguage},
            onSelectionChanged: (selection) => onChanged(selection.first),
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              backgroundColor: Colors.white12,
              foregroundColor: Colors.white70,
              selectedBackgroundColor: Colors.blue,
              selectedForegroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
            ),
          ),
        ],
      ),
    );
  }
}
