import 'package:eefood/features/chatbot/presentation/widgets/shopping_list_card/shopping_message_card.dart';
import 'package:eefood/features/recipe/data/models/shopping_item_model.dart';
import 'package:flutter/material.dart';

class ShoppingMessageListCard extends StatefulWidget {
  final List<ShoppingItemModel> listItem;
  const ShoppingMessageListCard({super.key, required this.listItem});

  @override
  State<ShoppingMessageListCard> createState() => _ShoppingMessageListCardState();
}

class _ShoppingMessageListCardState extends State<ShoppingMessageListCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.listItem.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = widget.listItem[index];
          return ShoppingMessageCard(item: item);
        },
      ),
    );
  }
}