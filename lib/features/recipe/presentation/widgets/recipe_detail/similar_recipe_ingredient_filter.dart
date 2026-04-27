import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../provider/similar_recipes_cubit.dart';

class SimilarRecipeIngredientFilter extends StatelessWidget {
  final int currentRecipeId;
  final List<String> availableIngredients;

  const SimilarRecipeIngredientFilter({
    super.key,
    required this.currentRecipeId,
    required this.availableIngredients,
  });

  Future<void> _showIngredientPicker(BuildContext context) async {
    final similarRecipesCubit = context.read<SimilarRecipesCubit>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey.shade50,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: similarRecipesCubit,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: BlocBuilder<SimilarRecipesCubit, SimilarRecipesState>(
                buildWhen: (previous, current) =>
                    previous.selectedIngredients != current.selectedIngredients,
                builder: (context, state) {
                  final selectedIngredients = state.selectedIngredients;

                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.65,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Chọn nguyên liệu ưu tiên',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${selectedIngredients.length} đã chọn',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (selectedIngredients.isNotEmpty)
                              TextButton(
                                onPressed: () => similarRecipesCubit
                                    .clearIngredients(currentRecipeId),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.orange.shade800,
                                ),
                                child: const Text('Xóa chọn'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: availableIngredients.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                color: Colors.grey.shade100,
                              ),
                              itemBuilder: (context, index) {
                                final ingredient = availableIngredients[index];
                                final isSelected = selectedIngredients.contains(
                                  ingredient,
                                );
                                final backgroundColor = index.isEven
                                    ? Colors.white
                                    : Colors.grey.shade100;

                                return Material(
                                  color: backgroundColor,
                                  child: InkWell(
                                    onTap: () =>
                                        similarRecipesCubit.toggleIngredient(
                                          currentRecipeId,
                                          ingredient,
                                        ),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 160,
                                          ),
                                          width: 4,
                                          height: 58,
                                          color: isSelected
                                              ? Colors.orange.shade600
                                              : Colors.transparent,
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 10,
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 34,
                                                  height: 34,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? Colors.orange.shade100
                                                        : Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors
                                                                .orange
                                                                .shade300
                                                          : Colors
                                                                .grey
                                                                .shade200,
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .restaurant_menu_rounded,
                                                    size: 18,
                                                    color: isSelected
                                                        ? Colors.orange.shade800
                                                        : Colors.grey.shade500,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    ingredient,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: isSelected
                                                          ? FontWeight.w700
                                                          : FontWeight.w500,
                                                      color:
                                                          Colors.grey.shade900,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Icon(
                                                  isSelected
                                                      ? Icons.check_circle
                                                      : Icons.circle_outlined,
                                                  color: isSelected
                                                      ? Colors.orange.shade700
                                                      : Colors.grey.shade400,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final similarRecipesCubit = context.read<SimilarRecipesCubit>();
    final selectedIngredients = context
        .watch<SimilarRecipesCubit>()
        .state
        .selectedIngredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Món tương tự',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            if (availableIngredients.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => _showIngredientPicker(context),
                icon: const Icon(Icons.tune_rounded, size: 18),
                label: const Text('Chọn nguyên liệu'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange.shade800,
                  side: BorderSide(color: Colors.orange.shade200),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        ),
        if (selectedIngredients.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedIngredients.map((ingredient) {
              return InputChip(
                label: Text(ingredient, overflow: TextOverflow.ellipsis),
                selected: true,
                selectedColor: Colors.orange.shade50,
                checkmarkColor: Colors.orange.shade800,
                deleteIconColor: Colors.orange.shade800,
                onDeleted: () => similarRecipesCubit.toggleIngredient(
                  currentRecipeId,
                  ingredient,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () =>
                similarRecipesCubit.clearIngredients(currentRecipeId),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor: Colors.orange.shade800,
            ),
            child: const Text('Xóa tất cả lựa chọn'),
          ),
        ],
      ],
    );
  }
}
