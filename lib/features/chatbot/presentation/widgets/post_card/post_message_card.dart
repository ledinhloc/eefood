import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/app_routes.dart';
import 'package:eefood/features/chatbot/presentation/provider/chatbot_cubit.dart';
import 'package:eefood/features/chatbot/presentation/provider/chatbot_state.dart';
import 'package:eefood/features/post/data/models/post_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostMessageCard extends StatelessWidget {
  final PostModel postModel;
  final bool enableSelection;
  const PostMessageCard({
    super.key,
    required this.postModel,
    this.enableSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enableSelection) return _buildCard(context, false);

    return BlocSelector<ChatbotCubit, ChatbotState, bool>(
      selector: (state) => state.selectedPosts.any((p) => p.id == postModel.id),
      builder: (context, isSelected) => _buildCard(context, isSelected),
    );
  }

  Widget _buildCard(BuildContext context, bool isSelected) {
    final theme = Theme.of(context);
    return GestureDetector(
      onLongPress: enableSelection
          ? () => context.read<ChatbotCubit>().togglePostSelection(postModel)
          : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (!enableSelection) {
            _navigateToDetail(context);
            return;
          }
          final hasAnySelected = context
              .read<ChatbotCubit>()
              .state
              .hasSelectedPosts;
          if (hasAnySelected) {
            context.read<ChatbotCubit>().togglePostSelection(postModel);
          } else {
            _navigateToDetail(context);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange.shade50 : theme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Colors.deepOrange.shade300
                  : Colors.transparent,
              width: isSelected ? 1.5 : 0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.deepOrange.withOpacity(0.12)
                    : Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: postModel.imageUrl,
                      height: 110,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        height: 110,
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.grey.shade400,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          postModel.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: isSelected
                                ? Colors.deepOrange.shade800
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        _buildMeta(),
                      ],
                    ),
                  ),
                ],
              ),

              if (enableSelection)
                Positioned(
                  top: 8,
                  right: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.deepOrange.shade500
                          : Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            size: 14,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

              if (enableSelection)
                BlocSelector<ChatbotCubit, ChatbotState, bool>(
                  selector: (state) =>
                      state.hasSelectedPosts &&
                      !state.selectedPosts.any((p) => p.id == postModel.id),
                  builder: (context, isDimmed) => AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isDimmed ? 0.45 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.recipeDetail,
      arguments: {'recipeId': postModel.recipeId},
    );
  }

  Widget _buildMeta() {
    final hasPrepTime = postModel.prepTime != null;
    final hasDifficulty = postModel.difficulty != null;

    if (!hasPrepTime && !hasDifficulty) return const SizedBox.shrink();

    return Row(
      children: [
        if (hasPrepTime)
          _MetaChip(
            icon: Icons.access_time_rounded,
            label: '${postModel.prepTime}p',
          ),
        if (hasPrepTime && hasDifficulty) const SizedBox(width: 6),
        if (hasDifficulty)
          Flexible(
            child: _MetaChip(
              icon: Icons.bar_chart_rounded,
              label: postModel.difficulty!,
            ),
          ),
      ],
    );
  }
}

/// Widget nhỏ hiển thị icon + text meta, tự co lại nếu text dài
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.deepOrange),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.deepOrange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
