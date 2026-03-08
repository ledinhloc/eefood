import 'package:eefood/features/livestream/presentation/widgets/viewer_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../provider/live_viewer_cubit.dart';
import '../provider/live_viewer_state.dart';

class ViewerListTab extends StatelessWidget {
  const ViewerListTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return BlocBuilder<LiveViewerCubit, LiveViewerState>(
      builder: (context, state) {

        if (state.loading) {
          return const Center(
            child: CircularProgressIndicator(
              color:  Color(0xFFFF6B35),
            ),
          );
        }

        if (state.viewers.isEmpty) {
          return const Center(
            child: Text(
              "Chưa có người xem",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          itemCount: state.viewers.length,
          itemBuilder: (context, index) {

            final viewer = state.viewers[index];

            return ViewerTile(viewer: viewer);
          },
        );
      },
    );
  }
}