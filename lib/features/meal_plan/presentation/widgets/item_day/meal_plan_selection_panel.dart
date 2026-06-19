import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MealPlanSelectionPanel extends StatelessWidget {
  final int selectedItemCount;
  final Color primaryWarm;
  final VoidCallback onCancel;
  final VoidCallback onRegenerate;

  const MealPlanSelectionPanel({
    super.key,
    required this.selectedItemCount,
    required this.primaryWarm,
    required this.onCancel,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primaryWarm.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryWarm.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.mealPlanSelectedItems(selectedItemCount),
                  style: TextStyle(
                    color: primaryWarm,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onCancel,
                tooltip: l10n.cancel,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  width: 32,
                  height: 32,
                ),
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          Text(
            l10n.mealPlanSelectItemsHint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onRegenerate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(Icons.auto_awesome),
              label: Text(l10n.mealPlanRegenerateAction),
            ),
          ),
        ],
      ),
    );
  }
}
