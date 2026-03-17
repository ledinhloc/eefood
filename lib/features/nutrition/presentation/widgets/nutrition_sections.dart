import 'dart:math';

import 'package:eefood/features/nutrition/data/models/nutrition_analysis_model.dart';
import 'package:eefood/features/nutrition/data/models/nutrition_display_models.dart';
import 'package:eefood/features/nutrition/presentation/utils/nutrition_helpers.dart';
import 'package:eefood/features/nutrition/presentation/widgets/display_nutrition/ingredient_nutrition_card.dart';
import 'package:eefood/features/nutrition/presentation/widgets/display_nutrition/nutrient_card.dart';
import 'package:eefood/features/nutrition/presentation/widgets/display_nutrition/pie_chart_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HealthScoreBanner extends StatelessWidget {
  final NutritionAnalysisModel data;
  final bool isDark;

  const HealthScoreBanner({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final score = (data.healthScore ?? 0.0).clamp(0.0, 10.0);
    final color = healthScoreColor(score);
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            // Score dial
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: score / 10,
                    strokeWidth: 6,
                    backgroundColor: isDark ? Colors.white12 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                  Text(
                    score.toStringAsFixed(1),
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chỉ số sức khỏe',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black45,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.healthLevel!,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.recommendation!,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NutritionPieChartSection extends StatefulWidget {
  final NutritionAnalysisModel data;
  final bool isDark;

  const NutritionPieChartSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  State<NutritionPieChartSection> createState() =>
      _NutritionPieChartSectionState();
}

class _NutritionPieChartSectionState extends State<NutritionPieChartSection> {
  int? _touchedIndex;
  static const double _chartSize = 160.0;
  static const double _center = _chartSize / 2;

  @override
  Widget build(BuildContext context) {
    final macros = buildMacroData(widget.data);
    final cardBg = widget.isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phân bổ dinh dưỡng',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: _chartSize,
                  height: _chartSize,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (event, response) {
                              setState(() {
                                // Nhả tay → ẩn tooltip
                                if (event is FlTapUpEvent ||
                                    event is FlLongPressEnd ||
                                    event is FlPanEndEvent) {
                                  _touchedIndex = null;
                                } else {
                                  _touchedIndex = response
                                      ?.touchedSection
                                      ?.touchedSectionIndex;
                                }
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: _buildSections(macros),
                        ),
                      ),
                      if (_touchedIndex != null &&
                          _touchedIndex! < macros.length)
                        _buildFloatingTooltip(macros, _touchedIndex!),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: macros
                        .map(
                          (m) => PieLegendItem(macro: m, isDark: widget.isDark),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 14,
                  color: widget.isDark ? Colors.white38 : Colors.black26,
                ),
                const SizedBox(width: 4),
                Text(
                  'Nhấn vào biểu đồ để xem chi tiết',
                  style: TextStyle(
                    color: widget.isDark ? Colors.white38 : Colors.black38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(List<MacroData> macros) {
    return macros.asMap().entries.map((entry) {
      final i = entry.key;
      final m = entry.value;
      final isTouched = i == _touchedIndex;
      return PieChartSectionData(
        color: m.color,
        value: m.value,
        title: '',
        radius: isTouched ? 55 : 48,
      );
    }).toList();
  }

  Widget _buildFloatingTooltip(List<MacroData> macros, int index) {
    final total = macros.fold(0.0, (sum, m) => sum + m.value);
    if (total == 0) return const SizedBox.shrink();

    // fl_chart bắt đầu từ đỉnh (-90°), chiều kim đồng hồ
    double startDeg = -90.0;
    for (int i = 0; i < macros.length; i++) {
      final sweep = (macros[i].value / total) * 360.0;
      if (i == index) {
        final midRad = (startDeg + sweep / 2) * pi / 180.0;
        // Đặt tooltip cách tâm ~(outerRadius + margin)
        const offset = 56.0 + 20.0; // touched radius + gap
        final dx = _center + offset * cos(midRad) - 28.0;
        final dy = _center + offset * sin(midRad) - 22.0;
        return Positioned(
          left: dx,
          top: dy,
          child: PieBadge(macro: macros[index]),
        );
      }
      startDeg += sweep;
    }
    return const SizedBox.shrink();
  }
}

class NutrientGridSection extends StatelessWidget {
  final NutritionAnalysisModel data;
  final bool isDark;

  const NutrientGridSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final nutrients = buildNutrientItems(data);
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Thành phần dinh dưỡng',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: nutrients.length,
            itemBuilder: (_, i) => NutrientCard(
              item: nutrients[i],
              cardBg: cardBg,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class NutritionSummarySection extends StatelessWidget {
  final NutritionAnalysisModel data;
  final bool isDark;

  const NutritionSummarySection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFFF6B00).withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_rounded,
                    color: Color(0xFFFF6B00),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Lời khuyên từ chuyên gia AI',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              data.summary!,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14.5,
                height: 1.6,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IngredientListSection extends StatelessWidget {
  final NutritionAnalysisModel data;
  final bool isDark;

  const IngredientListSection({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final ingredients = data.ingredientDetails;
    if (ingredients == null || ingredients.isEmpty)
      return const SizedBox.shrink();

    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Dinh dưỡng theo nguyên liệu',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          ...ingredients.asMap().entries.map(
            (e) => IngredientNutritionCard(
              ingredient: e.value,
              index: e.key,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}
