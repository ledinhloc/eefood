import 'package:eefood/features/livestream/data/model/live_gift_item_response.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_state.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_animation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveGiftOverlayLayer extends StatelessWidget {
  final List<LiveGiftItemResponse> giftCatalog;
  const LiveGiftOverlayLayer({super.key, required this.giftCatalog});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveGiftCubit, LiveGiftState>(
      buildWhen: (prev, curr) => prev.incomingGifts != curr.incomingGifts,
      builder: (context, state) {
        return IgnorePointer(
          child: Stack(
            children: state.incomingGifts.map((gift) {
              return LiveGiftAnimationCard(
                key: ValueKey(gift.giftLogId),
                gift: gift,
                onComplete: () =>
                    context.read<LiveGiftCubit>().removeIncomingGift(gift),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
