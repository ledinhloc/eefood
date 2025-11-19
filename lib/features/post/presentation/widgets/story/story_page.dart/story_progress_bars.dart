import 'package:flutter/material.dart';

class StoryProgressBars extends StatelessWidget {
  final int count;
  final int index;
  final double progress;

  const StoryProgressBars({
    super.key,
    required this.count,
    required this.index,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: List.generate(count, (i) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              decoration: BoxDecoration(
                color: i < index
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
              child: i == index
                  ? FractionallySizedBox(
                      widthFactor: progress,
                      alignment: Alignment.centerLeft,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        decoration: BoxDecoration(
                          color: Colors.orange, // màu nổi bật
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orangeAccent.withOpacity(0.8),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
