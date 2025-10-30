import 'dart:io';
import 'package:eefood/app_routes.dart';
import 'package:eefood/features/recipe/presentation/provider/recipe_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'instruction_bottom_sheet.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

class InstructionsSection extends StatefulWidget {
  const InstructionsSection({Key? key}) : super(key: key);

  @override
  State<InstructionsSection> createState() => _InstructionsSectionState();
}

class _InstructionsSectionState extends State<InstructionsSection> {
  void _addInstruction() {
    final cubit = context.read<RecipeCrudCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: InstructionBottomSheet(
            onSaveInstruction: (instruction, {int? index}) {
              cubit.addStep(instruction);
            },
          ),
        ),
      ),
    );
  }

  void _editInstruction(int index) {
    final cubit = context.read<RecipeCrudCubit>();
    final instruction = cubit.state.steps[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocProvider.value(
        value: cubit,
        child: InstructionBottomSheet(
          editingInstruction: instruction,
          editingIndex: index,
          onSaveInstruction: (updatedInstruction, {int? index}) {
            if (index != null) {
              cubit.updateStep(index, updatedInstruction);
            }
          },
        ),
      ),
    );
  }

  void _removeInstruction(int index) {
    final cubit = context.read<RecipeCrudCubit>();
    cubit.removeStep(index);
  }

  void _reorderInstructions(int oldIndex, int newIndex) {
    final cubit = context.read<RecipeCrudCubit>();
    if (cubit.state.steps.length <= 1) {
      return;
    }
    cubit.reorderSteps(oldIndex, newIndex);
  }

  void _openImageFullScreen(String imagePath) {
    Navigator.pushNamed(context, AppRoutes.mediaView, arguments: {
      'isVideo': false,
      'url': imagePath
    });
  }

  void _openVideoFullScreen(String videoPath) {
    Navigator.pushNamed(context, AppRoutes.mediaView, arguments: {
      'isVideo': true,
      'url': videoPath
    });
  }

  Widget _buildInstructionCard(RecipeStepModel step, int index) {
    final cubit = context.read<RecipeCrudCubit>();

    // Key mới dựa trên ID + hash media để rebuild tự động khi media thay đổi
    final cardKey = ValueKey(step.id ?? index);

    return Padding(
      key: cardKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey, width: 0.5),
        ),
        elevation: 4,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Step Header ---
              Row(
                children: [
                  Text(
                    'Step ${step.stepNumber}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () => _editInstruction(index),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.black),
                    onPressed: () => _removeInstruction(index),
                  ),
                ],
              ),
              const Divider(color: Colors.grey, height: 20),

              // --- Instruction Text ---
              Text(
                step.instruction ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Time: ${step.stepTime}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),

              // --- Image Section ---
              if (step.imageUrl != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _openImageFullScreen(step.imageUrl!),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          step.imageUrl!,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              cubit.updateStep(
                                index,
                                step.copyWith(imageUrl: null),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // --- Video Section ---
              if (step.videoUrl != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _openVideoFullScreen(step.videoUrl!),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          height: 180,
                          color: Colors.black,
                          child: step.imageUrl != null
                              ? Image.file(
                                  File(step.imageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                      ),
                      const Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            size: 60,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<RecipeCrudCubit>().state;
    final instructions = state.steps;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Instructions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (instructions.isEmpty)
            const Center(
              child: Text(
                'No instructions added yet',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: ReorderableListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                onReorder: _reorderInstructions,
                itemCount: instructions.length,
                itemBuilder: (context, index) {
                  final step = instructions[index];
                  return _buildInstructionCard(step, index);
                },
              ),
            ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _addInstruction,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Instruction',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
