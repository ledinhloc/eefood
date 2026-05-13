import 'package:eefood/features/chatbot/presentation/widgets/nutrition_card/painter_nutrition.dart';
import 'package:flutter/material.dart';

class NutritionScoreSection extends StatelessWidget {
  final double? score;
  final Color color;
  final String? level;
  final double? totalCalories;
  final Animation<double> animation;
  const NutritionScoreSection({
    super.key,
    required this.score,
    required this.color,
    required this.level,
    required this.totalCalories,
    required this.animation,
  });

  String _healthEmoji(String? level) {
    switch (level?.toLowerCase()) {
      case 'tốt':
      case 'good':
        return '🟢';
      case 'trung bình':
      case 'medium':
        return '🟡';
      case 'kém':
      case 'poor':
        return '🔴';
      default:
        return '⚪';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                final animatedScore = (score ?? 0) * animation.value;
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: ScoreGaugePainter(
                        progress: animatedScore / 100,
                        color: color,
                        backgroundColor: Colors.grey.shade100,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            animatedScore.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: color,
                              height: 1,
                            ),
                          ),
                          Text(
                            '/100',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _healthEmoji(level),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      level ?? 'Chưa xác định',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (context, _) => LinearProgressIndicator(
                      value: ((score ?? 0) / 100) * animation.value,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${(totalCalories ?? 0).toStringAsFixed(0)} kCal / khẩu phần',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
