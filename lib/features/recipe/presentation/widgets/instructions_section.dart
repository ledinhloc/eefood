import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'instruction_bottom_sheet.dart';
import 'package:eefood/features/recipe/data/models/recipe_step_model.dart';

class InstructionsSection extends StatefulWidget {
  final List<RecipeStepModel> instructions;
  final VoidCallback onInstructionsUpdated;

  const InstructionsSection({
    Key? key,
    required this.instructions,
    required this.onInstructionsUpdated,
  }) : super(key: key);

  @override
  State<InstructionsSection> createState() => _InstructionsSectionState();
}

class _InstructionsSectionState extends State<InstructionsSection> {
  static const double _itemHeight = 140.0; // chiều cao ước lượng 1 item
  static const double _maxListHeight = 420.0; // chiều cao tối đa của list

  void _addInstruction() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: InstructionBottomSheet(
          onSaveInstruction: (instruction, {int? index}) {
            setState(() {
              widget.instructions.add(instruction);
            });
            widget.onInstructionsUpdated();
          },
        ),
      ),
    );
  }

  void _editInstruction(int index) {
    final instruction = widget.instructions[index];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => InstructionBottomSheet(
        editingInstruction: instruction,
        editingIndex: index,
        onSaveInstruction: (updatedInstruction, {int? index}) {
          if (index != null) {
            setState(() {
              widget.instructions[index] = updatedInstruction;
            });
            widget.onInstructionsUpdated();
          }
        },
      ),
    );
  }

  void _removeInstruction(int index) {
    setState(() {
      widget.instructions.removeAt(index);
      // cập nhật lại stepNumber
      for (int i = 0; i < widget.instructions.length; i++) {
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

  void _reorderInstructions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = widget.instructions.removeAt(oldIndex);
      widget.instructions.insert(newIndex, item);

      // cập nhật lại stepNumber
      for (int i = 0; i < widget.instructions.length; i++) {
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

  Widget _buildInstructionCard(RecipeStepModel step, int index) {
    return InkWell(
      onTap: () =>
          _editInstruction(index), // nhấn vào card sẽ mở bottom sheet edit
      child: Card(
        key: ValueKey(step.id ?? 'instruction_$index'),
        margin: const EdgeInsets.only(bottom: 0),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Step ${step.stepNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeInstruction(index),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(step.instruction ?? ''),
              Text('Time: ${step.stepTime}'),
              if (step.imageUrl != null) ...[
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(step.imageUrl!)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            widget.instructions[index] = RecipeStepModel(
                              id: step.id,
                              stepNumber: step.stepNumber,
                              instruction: step.instruction,
                              imageUrl: null,
                              videoUrl: step.videoUrl,
                              stepTime: step.stepTime,
                            );
                          });
                          widget.onInstructionsUpdated();
                        },
                      ),
                    ),
                  ],
                ),
              ],
              if (step.videoUrl != null) ...[
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(step.videoUrl!)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: const Icon(
                        Icons.play_circle_fill,
                        size: 50,
                        color: Colors.white70,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            widget.instructions[index] = RecipeStepModel(
                              id: step.id,
                              stepNumber: step.stepNumber,
                              instruction: step.instruction,
                              imageUrl: step.imageUrl,
                              videoUrl: null,
                              stepTime: step.stepTime,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double listHeight = min(
      widget.instructions.length * _itemHeight,
      _maxListHeight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Instructions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (widget.instructions.isEmpty)
          const Center(
            child: Text(
              'No instructions added yet',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          SizedBox(
            height: listHeight,
            child: ReorderableListView(
              buildDefaultDragHandles: true,
              onReorder: _reorderInstructions,
              children: List.generate(widget.instructions.length, (index) {
                final instruction = widget.instructions[index];
                return SizedBox(
                  key: ValueKey(instruction.id ?? 'instruction_$index'),
                  width: double.infinity,
                  child: _buildInstructionCard(instruction, index),
                );
              }),
            ),
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
