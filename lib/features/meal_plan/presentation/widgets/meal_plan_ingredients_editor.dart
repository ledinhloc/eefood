import 'package:eefood/features/meal_plan/data/model/meal_plan_item_ingredient_response.dart';
import 'package:eefood/features/meal_plan/data/model/meal_plan_item_ingredient_upsert_request.dart';
import 'package:flutter/material.dart';

class MealPlanIngredientDraft {
  final TextEditingController nameController;
  final TextEditingController quantityController;
  final TextEditingController unitController;
  final TextEditingController noteController;

  MealPlanIngredientDraft({
    required this.nameController,
    required this.quantityController,
    required this.unitController,
    required this.noteController,
  });

  factory MealPlanIngredientDraft.empty() {
    return MealPlanIngredientDraft(
      nameController: TextEditingController(),
      quantityController: TextEditingController(),
      unitController: TextEditingController(),
      noteController: TextEditingController(),
    );
  }

  factory MealPlanIngredientDraft.fromResponse(
    MealPlanItemIngredientResponse item,
  ) {
    return MealPlanIngredientDraft(
      nameController: TextEditingController(text: item.name ?? ''),
      quantityController: TextEditingController(text: item.quantity ?? ''),
      unitController: TextEditingController(text: item.unit ?? ''),
      noteController: TextEditingController(text: item.note ?? ''),
    );
  }

  MealPlanItemIngredientUpsertRequest? toRequest() {
    final name = nameController.text.trim();
    final quantity = quantityController.text.trim();
    final unit = unitController.text.trim();
    final note = noteController.text.trim();

    final hasValue =
        name.isNotEmpty ||
        quantity.isNotEmpty ||
        unit.isNotEmpty ||
        note.isNotEmpty;
    if (!hasValue) return null;

    return MealPlanItemIngredientUpsertRequest(
      name: name.isEmpty ? null : name,
      quantity: quantity.isEmpty ? null : quantity,
      unit: unit.isEmpty ? null : unit,
      note: note.isEmpty ? null : note,
    );
  }

  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    noteController.dispose();
  }
}

class MealPlanIngredientsEditor extends StatelessWidget {
  final List<MealPlanIngredientDraft> drafts;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  const MealPlanIngredientsEditor({
    super.key,
    required this.drafts,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IngredientSectionHeader(onAdd: onAdd),
        if (drafts.isEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBF7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF2E6D9)),
            ),
            child: Text(
              'Chưa có nguyên liệu nào cho món này.',
              style: TextStyle(color: Colors.brown.shade600),
            ),
          )
        else
          ...List.generate(
            drafts.length,
            (index) => Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _IngredientEditorCard(
                index: index,
                draft: drafts[index],
                onRemove: () => onRemove(index),
              ),
            ),
          ),
      ],
    );
  }
}

class _IngredientSectionHeader extends StatelessWidget {
  final VoidCallback onAdd;

  const _IngredientSectionHeader({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Nguyên liệu',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Thêm'),
        ),
      ],
    );
  }
}

class _IngredientEditorCard extends StatelessWidget {
  final int index;
  final MealPlanIngredientDraft draft;
  final VoidCallback onRemove;

  const _IngredientEditorCard({
    required this.index,
    required this.draft,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2E6D9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Nguyên liệu ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Xóa nguyên liệu',
              ),
            ],
          ),
          TextField(
            controller: draft.nameController,
            decoration: InputDecoration(
              labelText: 'Tên nguyên liệu',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: draft.quantityController,
                  decoration: InputDecoration(
                    labelText: 'Số lượng',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: draft.unitController,
                  decoration: InputDecoration(
                    labelText: 'Đơn vị',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: draft.noteController,
            minLines: 1,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Ghi chú nguyên liệu',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
