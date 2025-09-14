import 'dart:io';
import 'package:flutter/material.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';
import 'instruction_bottom_sheet.dart';

class InstructionsSection extends StatefulWidget {
  final List<RecipeStepModel> instructions;
  final VoidCallback onInstructionsUpdated;

  const InstructionsSection({
    Key? key,
    required this.instructions,
    required this.onInstructionsUpdated,
  }) : super(key: key);

  @override
  _InstructionsSectionState createState() => _InstructionsSectionState();
}

class _InstructionsSectionState extends State<InstructionsSection> {
  void _addInstruction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InstructionBottomSheet(
        onAddInstruction: (instruction) {
          setState(() {
            widget.instructions.add(
              RecipeStepModel(
                id: instruction.id,
                stepNumber: widget.instructions.length + 1,
                instruction: instruction.instruction,
                imageUrl: instruction.imageUrl,
                videoUrl: instruction.videoUrl,
                stepTime: instruction.stepTime,
              ),
            );
          });
          widget.onInstructionsUpdated();
        },
      ),
    );
  }

  void _removeInstruction(int index) {
    setState(() {
      widget.instructions.removeAt(index);
      for (int i = index; i < widget.instructions.length; i++) {
        final old = widget.instructions[i];
        widget.instructions[i] = RecipeStepModel(
          id: old.id,
          stepNumber: i + 1,
          instruction: old.instruction,
          imageUrl: old.imageUrl,
          videoUrl: old.videoUrl,
          stepTime: old.stepTime,
        );
      }
    });
    widget.onInstructionsUpdated();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Instructions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        if (widget.instructions.isEmpty)
          const Center(
            child: Text('No instructions added yet', style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.instructions.length,
            itemBuilder: (context, index) {
              final instruction = widget.instructions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Step ${instruction.stepNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeInstruction(index),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(instruction.instruction ?? ''),
                      if (instruction.imageUrl != null) ...[
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(instruction.imageUrl!)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    final old = widget.instructions[index];
                                    widget.instructions[index] = RecipeStepModel(
                                      id: old.id,
                                      stepNumber: old.stepNumber,
                                      instruction: old.instruction,
                                      imageUrl: null,
                                      videoUrl: old.videoUrl,
                                      stepTime: old.stepTime,
                                    );
                                  });
                                  widget.onInstructionsUpdated();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (instruction.videoUrl != null) ...[
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: FileImage(File(instruction.videoUrl!)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: const Icon(Icons.play_circle_fill, size: 50, color: Colors.white70),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    final old = widget.instructions[index];
                                    widget.instructions[index] = RecipeStepModel(
                                      id: old.id,
                                      stepNumber: old.stepNumber,
                                      instruction: old.instruction,
                                      imageUrl: old.imageUrl,
                                      videoUrl: null,
                                      stepTime: old.stepTime,
                                    );
                                  });
                                  widget.onInstructionsUpdated();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 16),
        Center(
          child: ElevatedButton.icon(
            onPressed: _addInstruction,
            icon: const Icon(Icons.add),
            label: const Text('Add Instruction'),
          ),
        ),
      ],
    );
  }
}