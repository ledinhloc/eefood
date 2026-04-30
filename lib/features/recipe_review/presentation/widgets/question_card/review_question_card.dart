import 'package:eefood/features/recipe_review/data/models/review_question_model.dart';
import 'package:eefood/features/recipe_review/presentation/widgets/question_card/option_title.dart';
import 'package:flutter/material.dart';

class ReviewQuestionCard extends StatelessWidget {
  final int index;
  final ReviewQuestionModel question;
  final int? selectedOptionId;
  final void Function(int optionId) onOptionSelected;
  const ReviewQuestionCard({
    super.key,
    required this.index,
    required this.question,
    required this.selectedOptionId,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isAnswered = selectedOptionId != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAnswered
              ? const Color(0xFFFF6B35).withOpacity(0.4)
              : const Color(0xFF2E2E2E),
          width: 1.5,
        ),
        boxShadow: isAnswered
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isAnswered
                        ? const Color(0xFFFF6B35)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isAnswered
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Color(0xFF666666),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.content ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Options
            ...?(question.options?.map((option) {
              final isSelected = option.id == selectedOptionId;
              return OptionTitle(
                option: option,
                isSelected: isSelected,
                onTap: () {
                  if (option.id != null) onOptionSelected(option.id!);
                },
              );
            }).toList()),
          ],
        ),
      ),
    );
  }
}
