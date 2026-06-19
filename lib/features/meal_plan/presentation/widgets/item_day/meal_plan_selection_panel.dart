import 'package:eefood/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MealPlanSelectionPanel extends StatelessWidget {
  final int selectedItemCount;
  final Color primaryWarm;
  final VoidCallback onCancel;
  final VoidCallback onRegenerate;
  final VoidCallback onAddToShopping;
  final bool isAddingToShopping;

  const MealPlanSelectionPanel({
    super.key,
    required this.selectedItemCount,
    required this.primaryWarm,
    required this.onCancel,
    required this.onRegenerate,
    required this.onAddToShopping,
    required this.isAddingToShopping,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryWarm.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryWarm.withValues(alpha: 0.20)),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isAddingToShopping ? null : onAddToShopping,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryWarm,
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(
                      color: primaryWarm.withValues(alpha: 0.45),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: isAddingToShopping
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_shopping_cart_outlined, size: 18),
                  label: Text(
                    l10n.mealPlanAddToShoppingAction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isAddingToShopping ? null : onRegenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryWarm,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(44),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: Text(
                    l10n.mealPlanRegenerateAction,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
