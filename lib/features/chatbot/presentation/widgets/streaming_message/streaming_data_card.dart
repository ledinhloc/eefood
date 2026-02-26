import 'package:eefood/features/chatbot/presentation/widgets/collection_card/collection_message_list_card.dart';
import 'package:eefood/features/chatbot/presentation/widgets/post_card/post_message_list_card.dart';
import 'package:eefood/features/chatbot/presentation/widgets/shopping_list_card/shopping_message_list_card.dart';
import 'package:eefood/features/post/data/models/collection_model.dart';
import 'package:eefood/features/post/data/models/post_model.dart';
import 'package:eefood/features/recipe/data/models/shopping_item_model.dart';
import 'package:flutter/material.dart';

class StreamingDataCard extends StatelessWidget {
  final String? metaType;
  final List<dynamic> data;
  final bool animate;
  const StreamingDataCard({
    required this.metaType,
    required this.data,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0.0 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    switch (metaType) {
      case 'SUGGEST_POST':
        return PostMessageListCard(
          postModel: data.map((e) => PostModel.fromJson(e)).toList(),
        );
      case 'GENERATE_COLLECTION':
        return CollectionMessageListCard(
          listCollection: data.map((e) => CollectionModel.fromJson(e)).toList(),
        );
      case 'GENERATE_SHOPPING_LIST':
        return ShoppingMessageListCard(
          listItem: data.map((e) => ShoppingItemModel.fromJson(e)).toList(),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                )
                .toList(),
          ),
        );
    }
  }
}
