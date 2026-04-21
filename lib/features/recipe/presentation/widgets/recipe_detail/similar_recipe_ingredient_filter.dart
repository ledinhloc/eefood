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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Chọn nguyên liệu ưu tiên',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (selectedIngredients.isNotEmpty)
                            TextButton(
                              onPressed: () => context
                                  .read<SimilarRecipesCubit>()
                                  .clearIngredients(currentRecipeId),
                              child: const Text('Xóa chọn'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Chạm để chọn hoặc bỏ chọn. Danh sách món tương tự sẽ tải lại ngay.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: availableIngredients.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final ingredient = availableIngredients[index];
                            final isSelected = selectedIngredients.contains(
                              ingredient,
                            );

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                ingredient,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.circle_outlined,
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey.shade400,
                              ),
                              onTap: () => context
                                  .read<SimilarRecipesCubit>()
                                  .toggleIngredient(
                                    currentRecipeId,
                                    ingredient,
                                  ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (availableIngredients.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedIngredients = context
        .watch<SimilarRecipesCubit>()
        .state
        .selectedIngredients;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: () => _showIngredientPicker(context),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: const Text('Chọn nguyên liệu'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange.shade800,
              side: BorderSide(color: Colors.orange.shade200),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          selectedIngredients.isEmpty
              ? 'Khám phá thêm 10 món gần giống với công thức này'
              : 'Đang ưu tiên món có các nguyên liệu bạn đã chọn',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                onDeleted: () => context
                    .read<SimilarRecipesCubit>()
                    .toggleIngredient(currentRecipeId, ingredient),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context
                .read<SimilarRecipesCubit>()
                .clearIngredients(currentRecipeId),
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
