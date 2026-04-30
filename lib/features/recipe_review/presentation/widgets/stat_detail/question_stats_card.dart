import 'package:eefood/features/recipe_review/data/models/question_state_model.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/stat_detail/option_row.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/stat_detail/pie_chart_section.dart';
import 'package:flutter/material.dart';

class QuestionStatsCard extends StatelessWidget {
  final QuestionStateModel question;
  final int? touchedIndex;
  final ValueChanged<int?> onTouch;
  const QuestionStatsCard({
    super.key,
    required this.question,
    required this.touchedIndex,
    required this.onTouch,
  });

  static const _colors = [
    Color(0xFFFF7043),
    Color(0xFFFFB300),
    Color(0xFF66BB6A),
    Color(0xFF42A5F5),
    Color(0xFFAB47BC),
    Color(0xFF26C6DA),
  ];

  @override
  Widget build(BuildContext context) {
    final options = question.options ?? [];
    final hasData = options.any((o) => (o.count ?? 0) > 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Câu hỏi",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  question.content ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (!hasData)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  "Chưa có dữ liệu",
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            )
          else ...[
            // Pie chart
            PieChartSection(
              options: options,
              colors: _colors,
              touchedIndex: touchedIndex,
              onTouch: onTouch,
            ),
            const SizedBox(height: 20),
            // Options breakdown
            ...options.asMap().entries.map(
              (e) => OptionRow(
                option: e.value,
                color: _colors[e.key % _colors.length],
                isHighlighted: touchedIndex == e.key,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
