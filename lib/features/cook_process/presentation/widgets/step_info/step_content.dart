import 'package:eefood/features/cook_process/presentation/widgets/countdown_timer.dart';
import 'package:eefood/features/cook_process/presentation/widgets/instruction_card.dart';
import 'package:eefood/features/cook_process/presentation/widgets/step_info/step_chip.dart';
import 'package:eefood/features/cook_process/presentation/widgets/step_info/step_image_carousel.dart';
import 'package:eefood/features/cook_process/presentation/widgets/step_time_info.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'package:flutter/material.dart';

class StepContent extends StatelessWidget {
  final RecipeStepModel step;
  final bool timerEnabled;
  final ValueChanged<bool>? onTimerRunningChanged;
  const StepContent({
    super.key,
    required this.step,
    required this.timerEnabled,
    this.onTimerRunningChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // Step header chip
          Row(
            children: [
              StepChip(stepNumber: step.stepNumber),
              const Spacer(),
              if (timerEnabled && step.stepTime != null && step.stepTime! > 0)
                CountdownTimer(
                  seconds: step.stepTime! * 60,
                  onRunningChanged: onTimerRunningChanged,
                  ),
            ],
          ),
          const SizedBox(height: 20),

          // Image
          if (step.imageUrls != null && step.imageUrls!.isNotEmpty)
            StepImageCarousel(imageUrls: step.imageUrls!),

          const SizedBox(height: 20),

          // Instruction
          if (step.instruction != null && step.instruction!.isNotEmpty)
            InstructionCard(instruction: step.instruction!),

          const SizedBox(height: 16),

          // Step time info
          if (step.stepTime != null && step.stepTime! > 0)
            StepTimeInfo(minutes: step.stepTime!),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
