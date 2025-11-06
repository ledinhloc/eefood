import 'dart:convert';

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/post/data/models/follow_model.dart';
import 'package:eefood/features/post/presentation/provider/follow_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowItemButton extends StatefulWidget {
  final FollowModel targetUser;
  const FollowItemButton({super.key, required this.targetUser});

  @override
  State<FollowItemButton> createState() => _FollowItemButtonState();
}

class _FollowItemButtonState extends State<FollowItemButton> {
  bool _isLoading = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    final id = await _getCurrentUserId();
    if (mounted) {
      setState(() {
        _currentUserId = id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu chưa load xong userId hoặc là chính mình
    if (_currentUserId == null || _currentUserId == widget.targetUser.id) {
      return const SizedBox();
    }

    return BlocBuilder<FollowCubit, FollowState>(
      builder: (context, state) {
        final isFollowing = state.followingList.any(
          (user) => user.id == widget.targetUser.id,
        );

        return _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(
                onPressed: () => _toggleFollow(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing
                      ? Colors.grey
                      : const Color(0xFFE67E22),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  isFollowing ? 'Đã theo dõi' : 'Theo dõi',
                  style: const TextStyle(fontSize: 12),
                ),
              );
      },
    );
  }

  Future<void> _toggleFollow(BuildContext context) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUserId = _currentUserId;
      if (currentUserId == null) return;
      await context.read<FollowCubit>().toggleFollow(widget.targetUser.id);
      await context.read<FollowCubit>().fetchFollowings(currentUserId);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<int?> _getCurrentUserId() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userString = prefs.getString('user');
      if (userString != null) {
        final userMap = jsonDecode(userString);
        return userMap['id'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
