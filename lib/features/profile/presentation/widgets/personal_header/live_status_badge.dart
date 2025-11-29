import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/di/injection.dart';
import '../../../../livestream/data/model/live_stream_response.dart';
import '../../../../livestream/presentation/provider/live_comment_cubit.dart';
import '../../../../livestream/presentation/provider/live_reaction_cubit.dart';
import '../../../../livestream/presentation/provider/watch_live_cubit.dart';
import '../../../../livestream/presentation/screens/live_viewer_screen.dart';
class LiveStatusBadge extends StatelessWidget {
  final LiveStreamResponse? stream;

  const LiveStatusBadge({Key? key, this.stream}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stream == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                      create: (_) => getIt<WatchLiveCubit>()
                  ),
                  BlocProvider(
                    create: (_) => getIt<LiveCommentCubit>()..loadComments(stream!.id),
                  ),
                  BlocProvider(
                    create: (_) => getIt<LiveReactionCubit>(param1: stream!.id)
                  ),
                ],
                child: LiveViewerScreen(streamId: stream!.id)),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.redAccent],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dot animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
              onEnd: () {
                // Loop animation
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'ĐANG PHÁT TRỰC TIẾP',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.play_circle_fill,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}