import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/features/post/data/models/follow_model.dart';
import 'package:eefood/features/post/data/models/story_setting_model.dart';
import 'package:eefood/features/post/presentation/provider/follow_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryUserSelectorPage extends StatefulWidget {
  final int userId;
  final StoryMode mode;
  final List<int> selectedUserIds;

  const StoryUserSelectorPage({
    super.key,
    required this.userId,
    required this.mode,
    required this.selectedUserIds,
  });

  @override
  State<StoryUserSelectorPage> createState() => _StoryUserSelectorPageState();
}

class _StoryUserSelectorPageState extends State<StoryUserSelectorPage> {
  late FollowCubit _followCubit;
  late Set<int> _selectedIds;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.selectedUserIds);
    _followCubit = context.read<FollowCubit>();
    _followCubit.fetchFollowers(widget.userId);

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _followCubit.fetchFollowers(widget.userId, loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.mode) {
      case StoryMode.CUSTOM_INCLUDE:
        return 'Chọn người có thể xem';
      case StoryMode.BLACKLIST:
        return 'Chọn người cần ẩn';
      default:
        return 'Chọn người dùng';
    }
  }

  void _toggleSelection(int userId) {
    setState(() {
      if (_selectedIds.contains(userId)) {
        _selectedIds.remove(userId);
      } else {
        _selectedIds.add(userId);
      }
    });
  }

  void _saveSelection() {
    Navigator.pop(context, _selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(_title, style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: _selectedIds.isEmpty ? null : _saveSelection,
            child: Text(
              'Xong (${_selectedIds.length})',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: _selectedIds.isEmpty ? Colors.grey : Colors.blue,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thông tin hướng dẫn
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.05),
            child: Text(
              widget.mode == StoryMode.CUSTOM_INCLUDE
                  ? 'Chọn những người bạn muốn cho phép xem tin của bạn'
                  : 'Chọn những người bạn muốn ẩn tin của mình',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),

          // Danh sách người theo dõi
          Expanded(
            child: BlocBuilder<FollowCubit, FollowState>(
              builder: (context, state) {
                if (state.isLoading && state.followerList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.followerList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có người theo dõi',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => _followCubit.fetchFollowers(
                    widget.userId,
                    loadMore: true,
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        state.followerList.length +
                        (state.hasMoreFollowers ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.followerList.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final user = state.followerList[index];
                      final userId = user.followerId ?? user.followingId ?? 0;
                      final isSelected = _selectedIds.contains(userId);

                      return _buildUserTile(user, userId, isSelected);
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

  Widget _buildUserTile(FollowModel user, int userId, bool isSelected) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? Colors.blue.withOpacity(0.05) : Colors.white,
      ),
      child: ListTile(
        onTap: () => _toggleSelection(userId),
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
              ? CachedNetworkImageProvider(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null || user.avatarUrl!.isEmpty
              ? Text(
                  user.username?.substring(0, 1).toUpperCase() ?? '?',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        title: Text(
          user.username ?? 'Người dùng',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: user.username != null
            ? Text(
                '@${user.username}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              )
            : null,
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => _toggleSelection(userId),
          activeColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
    );
  }
}
