import 'package:eefood/features/post/presentation/provider/story_viewer_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryViewerListSheet extends StatefulWidget {
  final int storyId;
  final StoryViewerCubit cubit;

  const StoryViewerListSheet({
    super.key,
    required this.cubit,
    required this.storyId,
  });

  @override
  State<StoryViewerListSheet> createState() => _StoryViewerListSheetState();
}

class _StoryViewerListSheetState extends State<StoryViewerListSheet> {
  final scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scroll.position.pixels >= scroll.position.maxScrollExtent - 80) {
      widget.cubit.loadViewer(storyId: widget.storyId, loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            height: 5,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Người xem story",
            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: BlocBuilder<StoryViewerCubit, StoryViewerState>(
              builder: (context, state) {
                if (state.isLoading && state.viewers.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await widget.cubit.loadViewer(
                      loadMore: true,
                      storyId: widget.storyId,
                    );
                  },
                  child: ListView.builder(
                    controller: scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: state.viewers.length + (state.isLoading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == state.viewers.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final v = state.viewers[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              (v.avatarUrl != null && v.avatarUrl!.isNotEmpty)
                              ? NetworkImage(v.avatarUrl!)
                              : null,
                        ),
                        title: Text(v.username ?? "Người dùng"),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
