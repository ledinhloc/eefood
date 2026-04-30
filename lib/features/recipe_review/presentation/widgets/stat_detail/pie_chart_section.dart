import 'package:eefood/features/recipe_review/data/models/option_state_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartSection extends StatelessWidget {
  final List<OptionStateModel> options;
  final List<Color> colors;
  final int? touchedIndex;
  final ValueChanged<int?> onTouch;
  const PieChartSection({
    super.key,
    required this.options,
    required this.colors,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, response) {
              if (!event.isInterestedForInteractions ||
                  response == null ||
                  response.touchedSection == null) {
                onTouch(null);
                return;
              }
              onTouch(response.touchedSection!.touchedSectionIndex);
            },
          ),
          sectionsSpace: 3,
          centerSpaceRadius: 50,
          sections: options.asMap().entries.map((e) {
            final i = e.key;
            final o = e.value;
            final isTouched = touchedIndex == i;
            final pct = (o.percent ?? 0);

            return PieChartSectionData(
              color: colors[i % colors.length],
              value: pct > 0 ? pct : 0.01,
              title: pct >= 5 ? '${pct.toStringAsFixed(0)}%' : '',
              radius: isTouched ? 80 : 65,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
