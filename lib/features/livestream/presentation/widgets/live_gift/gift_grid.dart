import 'package:eefood/features/livestream/data/model/live_gift_item_response.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/gift_card.dart';
import 'package:flutter/material.dart';

class GiftGrid extends StatelessWidget {
  final List<LiveGiftItemResponse> gifts;
  final LiveGiftItemResponse? selected;
  const GiftGrid({super.key, required this.gifts, required this.selected});

  @override
  Widget build(BuildContext context) {
    if (gifts.isEmpty) {
      return Center(
        child: Text(
          'Không có quà tặng',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.78,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) {
        final gift = gifts[index];
        final isSelected = selected?.id == gift.id;
        return GiftCard(gift: gift, isSelected: isSelected);
      },
    );
  }
}
