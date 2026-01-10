import 'package:eefood/features/post/presentation/provider/follow_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/follow/follow_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowListPage extends StatefulWidget {
  final bool isFollowers;
  final int userId;
  final FollowCubit followCubit;

  const FollowListPage({
    super.key,
    required this.isFollowers,
    required this.userId,
    required this.followCubit,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  final _scrollController = ScrollController();
  late final FollowCubit cubit;
  int? _lastLoadedUserId;

  @override
  void initState() {
    super.initState();
    cubit = widget.followCubit;
    debugPrint('Follow list page userId: ${widget.userId}');

    if (_lastLoadedUserId != widget.userId) {
      cubit.resetListState();
      _lastLoadedUserId = widget.userId;
    }

    // Chỉ load nếu list đang trống
    final hasData = widget.isFollowers
        ? cubit.state.followerList.isNotEmpty
        : cubit.state.followingList.isNotEmpty;

    if (!hasData) {
      _loadFollow();
    }

    _scrollController.addListener(_onScroll);
  }

  void _loadFollow() async {
    widget.isFollowers
        ? await cubit.fetchFollowers(widget.userId)
        : await cubit.fetchFollowings(widget.userId);
  }

  void _onScroll() async {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !cubit.state.isLoading) {
      widget.isFollowers
          ? await cubit.fetchFollowers(widget.userId, loadMore: true)
          : await cubit.fetchFollowings(widget.userId, loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isFollowers ? 'Người theo dõi' : 'Đang theo dõi';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: BlocBuilder<FollowCubit, FollowState>(
        builder: (context, state) {
          final users = widget.isFollowers
              ? state.followerList
              : state.followingList;

          if (state.isLoading && users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              final cubit = widget.followCubit;
              widget.isFollowers
                  ? await cubit.fetchFollowers(widget.userId)
                  : await cubit.fetchFollowings(widget.userId);
            },
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: users.length + (state.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == users.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = users[index];
                return FollowItem(
                  user: user,
                  isFollowersList: widget.isFollowers,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
