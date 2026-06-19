import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../provider/live_viewer_cubit.dart';
import '../../provider/live_viewer_state.dart';
import 'viewer_tile.dart';

class ViewerListTab extends StatelessWidget {
  const ViewerListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LiveViewerCubit, LiveViewerState>(
      builder: (context, state) {
        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
          );
        }

        if (state.viewers.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Color(0x146C63FF),
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: Icon(
                        Icons.people_outline_rounded,
                        color: Color(0xFF8B85FF),
                        size: 34,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có người xem',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Người tham gia livestream sẽ xuất hiện tại đây.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, height: 1.4),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          itemCount: state.viewers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return ViewerTile(viewer: state.viewers[index]);
          },
        );
      },
    );
  }
}
