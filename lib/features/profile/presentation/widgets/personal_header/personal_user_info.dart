import 'dart:convert';
import 'package:eefood/app_routes.dart';
import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
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

  @override
  void initState() {
    super.initState();
    _followCubit = getIt<FollowCubit>();
    _getCurrentUserId();
  }

  /// Lấy thông tin user hiện tại từ SharedPreferences
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
      // Sau khi có ID, load dữ liệu follow
      _followCubit.loadFollowData(widget.user.id);
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
            padding: const EdgeInsets.only(bottom: 16),
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
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.followListPage,
                arguments: {
                  'isFollowers': true,
                  'userId': widget.user.id,
                  'followCubit': _followCubit, // Thêm dòng này
                },
              );
            },
          ),
          const VerticalDivider(),
          StartItem(
            title: 'Đang theo dõi',
            value: state.followings.toString(),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.followListPage,
                arguments: {
                  'isFollowers': false,
                  'userId': widget.user.id,
                  'followCubit': _followCubit, // Thêm dòng này
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context, FollowState state) {
    return SizedBox(
      width: 180,
      height: 44,
      child: ElevatedButton(
        onPressed: state.isLoading
            ? null
            : () => _followCubit.toggleFollow(widget.user.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: state.isFollowing
              ? Colors.grey
              : const Color(0xFFE67E22),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: state.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                state.isFollowing ? 'Đã theo dõi' : 'Theo dõi',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }
}
