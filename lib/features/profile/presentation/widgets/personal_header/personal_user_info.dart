import 'dart:convert';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/button_skeleton_loading.dart';
import 'package:eefood/features/post/presentation/provider/follow_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:eefood/core/widgets/user_avatar.dart';
import 'package:eefood/features/auth/domain/entities/user.dart';
import 'package:eefood/features/profile/presentation/widgets/personal_header/start_item.dart';

class PersonalUserInfo extends StatefulWidget {
  final User user;

  const PersonalUserInfo({super.key, required this.user});

  @override
  State<PersonalUserInfo> createState() => _PersonalUserInfoState();
}

class _PersonalUserInfoState extends State<PersonalUserInfo> {
  int? _currentUserId;
  bool _isLoadingUser = true;
  late final FollowCubit _followCubit;
  bool _isOptimisticFollowing = false;

  @override
  void initState() {
    super.initState();
    _followCubit = getIt<FollowCubit>();
    _getCurrentUserId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentUserId != null && !_isLoadingUser) {
      _followCubit.loadFollowData(widget.user.id);
    }
  }

  Future<void> _getCurrentUserId() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final userString = prefs.getString(AppKeys.user);
      if (userString != null) {
        final userMap = jsonDecode(userString);
        _currentUserId = userMap['id'];
      }
    } catch (_) {
      // ignore lỗi parse JSON
    } finally {
      setState(() {
        _isLoadingUser = false;
      });

      await _followCubit.loadFollowData(widget.user.id);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool get _isOwnProfile => _currentUserId == widget.user.id;

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return BlocProvider.value(
      value: _followCubit,
      child: BlocBuilder<FollowCubit, FollowState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Hero(
                  tag: 'user_avatar_${widget.user.username}',
                  child: UserAvatar(
                    username: widget.user.username,
                    isLocal: false,
                    radius: 55,
                    url: widget.user.avatarUrl,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.user.username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStats(context, state),
                const SizedBox(height: 16),
                if (!_isOwnProfile) _buildFollowButton(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStats(BuildContext context, FollowState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const StartItem(title: 'Bài viết', value: '128'),
          const VerticalDivider(),
          StartItem(
            title: 'Người theo dõi',
            value: state.followers.toString(),
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.followListPage,
                arguments: {
                  'isFollowers': true,
                  'userId': widget.user.id,
                  'followCubit': _followCubit,
                },
              );
              await _followCubit.loadFollowData(widget.user.id);
            },
          ),
          const VerticalDivider(),
          StartItem(
            title: 'Đang theo dõi',
            value: state.followings.toString(),
            onTap: () async {
              await Navigator.pushNamed(
                context,
                AppRoutes.followListPage,
                arguments: {
                  'isFollowers': false,
                  'userId': widget.user.id,
                  'followCubit': _followCubit,
                },
              );
              await _followCubit.loadFollowData(widget.user.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, FollowState state) {
    if (state.isLoading && state.followers == 0 && state.followings == 0) {
      return const LoadingSkeletonButton();
    }

    // Sử dụng optimistic state nếu đang loading
    final displayFollowing = state.isLoading
        ? _isOptimisticFollowing
        : state.isFollowing;

    return SizedBox(
      width: 180,
      height: 44,
      child: ElevatedButton(
        onPressed: state.isLoading
            ? null
            : () {
                // Cập nhật UI ngay lập tức
                setState(() {
                  _isOptimisticFollowing = !state.isFollowing;
                });

                // Gọi API
                _followCubit.toggleFollow(
                  widget.user.id,
                  _currentUserId!,
                  profileUserId: widget.user.id,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: displayFollowing
              ? Colors.grey.shade400
              : const Color(0xFFE67E22),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          // Giảm opacity nhẹ khi loading
          elevation: state.isLoading ? 1 : 2,
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: state.isLoading ? 0.7 : 1.0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(displayFollowing ? Icons.check : Icons.add, size: 18),
              const SizedBox(width: 6),
              Text(
                displayFollowing ? 'Đã theo dõi' : 'Theo dõi',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
