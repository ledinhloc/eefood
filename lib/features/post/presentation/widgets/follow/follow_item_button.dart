import 'dart:convert';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/follow_model.dart';
import 'package:eefood/features/post/presentation/provider/follow_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowItemButton extends StatefulWidget {
  final FollowModel targetUser;
  final bool isFollowersList;

  const FollowItemButton({
    super.key,
    required this.targetUser,
    required this.isFollowersList,
  });

  @override
  State<FollowItemButton> createState() => _FollowItemButtonState();
}

class _FollowItemButtonState extends State<FollowItemButton> {
  bool _isLoading = false;
  int? _currentUserId;
  late bool _isFollow; // <-- lưu trạng thái follow tạm thời

  @override
  void initState() {
    super.initState();
    _isFollow = widget.targetUser.isFollow ?? false;
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final id = await _getCurrentUserId();
    if (mounted) setState(() => _currentUserId = id);
  }

  int get displayedUserId {
    return widget.isFollowersList
        ? widget.targetUser.followerId
        : widget.targetUser.followingId;
  }

  bool get isSelf =>
      _currentUserId != null && _currentUserId == displayedUserId;

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null || isSelf) {
      return const SizedBox();
    }

    return _isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : ElevatedButton(
            onPressed: () => _toggleFollow(context, displayedUserId),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isFollow
                  ? Colors.grey
                  : const Color(0xFFE67E22),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _isFollow ? 'Đã theo dõi' : 'Theo dõi',
              style: const TextStyle(fontSize: 12),
            ),
          );
  }

  Future<void> _toggleFollow(BuildContext context, int targetUserId) async {
    if (_isLoading || _currentUserId == null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<FollowCubit>().toggleFollow(
        targetUserId,
        _currentUserId!,
        targetUser: widget.targetUser,
      );

      // Cập nhật UI ngay lập tức (optimistic update)
      setState(() {
        _isFollow = !_isFollow;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<int?> _getCurrentUserId() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userString = prefs.getString(AppKeys.user);
      if (userString != null) {
        final userMap = jsonDecode(userString);
        return userMap['id'] as int?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
