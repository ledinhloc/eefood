import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:flutter/material.dart';

class MealPlanActionButton extends StatelessWidget {
  final VoidCallback onGenerateTap;
  final VoidCallback onDeleteTap;

  const MealPlanActionButton({
    super.key,
    required this.onGenerateTap,
    required this.onDeleteTap,
  });

  Future<void> _openActions(BuildContext context) async {
    await showCustomBottomSheet(context, [
      BottomSheetOption(
        icon: const Icon(Icons.auto_awesome_outlined, color: Colors.orange),
        title: 'Tao plan AI',
        onTap: onGenerateTap,
      ),
      BottomSheetOption(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        title: 'Xoa meal plan',
        onTap: onDeleteTap,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _openActions(context),
      icon: const Icon(Icons.more_horiz_rounded),
      tooltip: 'Thao tac meal plan',
    );
  }
}
