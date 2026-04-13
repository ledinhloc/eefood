import 'package:eefood/features/cook_process/presentation/provider/ingredient_alter_cubit.dart';
import 'package:eefood/features/cook_process/presentation/provider/ingredient_alter_state.dart';
import 'package:eefood/features/recipe/data/models/recipe_Ingredient_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IngredientSubstituteSheet extends StatelessWidget {
  final RecipeIngredientModel ingre;
  final int recipeId;

  const IngredientSubstituteSheet({
    required this.ingre,
    required this.recipeId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IngredientAlterCubit, IngredientAlterState>(
      builder: (context, state) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _DragHandle(),
              _SheetHeader(ingre: ingre),
              Expanded(
                child: _SheetBody(
                  state: state,
                  ingre: ingre,
                  recipeId: recipeId,
                ),
              ),
              _ConfirmButton(state: state, ingre: ingre, recipeId: recipeId),
            ],
          ),
        );
      },
    );
  }
}

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final RecipeIngredientModel ingre;
  const _SheetHeader({required this.ingre});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nguyên liệu thay thế',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (ingre.ingredient?.name != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                ingre.ingredient!.name,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ),
        ],
      ),
    );
  }
}

class _SheetBody extends StatelessWidget {
  final IngredientAlterState state;
  final RecipeIngredientModel ingre;
  final int recipeId;

  const _SheetBody({
    required this.state,
    required this.ingre,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFF97316),
          strokeWidth: 2.5,
        ),
      );
    }

    if (state.error != null) {
      return _ErrorView(
        message: state.error!,
        ingre: ingre,
        recipeId: recipeId,
      );
    }

    final data = state.data;
    if (data == null || data.substitute!.isEmpty) {
      return _EmptyView();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: data.substitute!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final item = data.substitute![index];
        final isSelected = data.selectedSubstitute?.id == item.id;
        final isSelecting = state.isSelecting;

        return _SubstituteItem(
          item: item,
          isSelected: isSelected,
          isSelecting: isSelecting,
          onTap: () {
            if (isSelecting) return;
            final ingredientId =
                ingre.ingredient?.originalId ?? ingre.ingredient?.id;
            if (ingredientId == null) return;
            context.read<IngredientAlterCubit>().select(
              recipeId,
              ingredientId,
              item.id!,
            );
          },
        );
      },
    );
  }
}

class _SubstituteItem extends StatelessWidget {
  final dynamic item; // thay bằng type cụ thể của bạn
  final bool isSelected;
  final bool isSelecting;
  final VoidCallback onTap;

  const _SubstituteItem({
    required this.item,
    required this.isSelected,
    required this.isSelecting,
    required this.onTap,
  });

  static const _brand = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? _brand : Colors.grey.shade200,
          width: isSelected ? 1.5 : 0.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _ItemThumbnail(imageUrl: item.image),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SelectIndicator(
                isSelected: isSelected,
                isLoading: isSelected && isSelecting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemThumbnail extends StatelessWidget {
  final String? imageUrl;
  const _ItemThumbnail({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? Image.network(
              imageUrl!,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    width: 48,
    height: 48,
    color: Colors.grey.shade100,
    child: Icon(
      Icons.image_not_supported_outlined,
      size: 22,
      color: Colors.grey.shade400,
    ),
  );
}

class _SelectIndicator extends StatelessWidget {
  final bool isSelected;
  final bool isLoading;

  const _SelectIndicator({required this.isSelected, required this.isLoading});

  static const _brand = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: _brand),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? _brand : Colors.transparent,
        border: Border.all(
          color: isSelected ? _brand : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 12, color: Colors.white)
          : null,
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final IngredientAlterState state;
  final RecipeIngredientModel ingre;
  final int recipeId;

  const _ConfirmButton({
    required this.state,
    required this.ingre,
    required this.recipeId,
  });

  static const _brand = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final hasSelection = state.data?.selectedSubstitute != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton(
          onPressed: hasSelection && !state.isSelecting
              ? () => Navigator.of(context).pop(state.data!.selectedSubstitute)
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: _brand,
            disabledBackgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            hasSelection ? 'Xác nhận thay thế' : 'Chọn nguyên liệu',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: hasSelection ? Colors.white : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final RecipeIngredientModel ingre;
  final int recipeId;

  const _ErrorView({
    required this.message,
    required this.ingre,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Không tải được dữ liệu',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                final ingredientId =
                    ingre.ingredient?.originalId ?? ingre.ingredient?.id;
                if (ingredientId == null) return;
                context.read<IngredientAlterCubit>().load(
                  recipeId,
                  ingredientId,
                );
              },
              child: const Text(
                'Thử lại',
                style: TextStyle(color: Color(0xFFF97316)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Không có nguyên liệu thay thế',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
