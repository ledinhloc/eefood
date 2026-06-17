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

  factory MealPlanIngredientDraft.fromName(String name) {
    return MealPlanIngredientDraft(
      nameController: TextEditingController(text: name),
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
