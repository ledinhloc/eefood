import 'package:eefood/features/livestream/data/model/live_gift_item_response.dart';
import 'package:eefood/features/livestream/data/model/send_gift_response.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_cubit.dart';
import 'package:eefood/features/livestream/presentation/provider/live_gift_state.dart';
import 'package:eefood/features/livestream/presentation/widgets/live_gift/live_gift_animation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveGiftOverlayLayer extends StatefulWidget {
  final List<LiveGiftItemResponse> giftCatalog;

  const LiveGiftOverlayLayer({super.key, required this.giftCatalog});

  @override
  State<LiveGiftOverlayLayer> createState() => _LiveGiftOverlayLayerState();
}

class _LiveGiftOverlayLayerState extends State<LiveGiftOverlayLayer> {
  final Map<int, SendGiftResponse> _displayingGifts = {};

  @override
  Widget build(BuildContext context) {
    return BlocListener<LiveGiftCubit, LiveGiftState>(
      listenWhen: (prev, curr) => prev.incomingGifts != curr.incomingGifts,
      listener: (context, state) {
        // Chỉ thêm gift chưa có trong map
        bool hasNew = false;
        for (final gift in state.incomingGifts) {
          if (!_displayingGifts.containsKey(gift.giftLogId)) {
            _displayingGifts[gift.giftLogId!] = gift;
            hasNew = true;
          }
        }
        if (hasNew) setState(() {});
      },
      child: IgnorePointer(
        child: Stack(
          children: _displayingGifts.values.map((gift) {
            return LiveGiftAnimationCard(
              key: ValueKey(gift.giftLogId),
              gift: gift,
              onComplete: () {
                setState(() {
                  _displayingGifts.remove(gift.giftLogId);
                });
                context.read<LiveGiftCubit>().removeIncomingGift(gift);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
