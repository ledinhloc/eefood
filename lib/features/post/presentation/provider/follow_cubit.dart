import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/follow_model.dart';
import 'package:eefood/features/post/domain/repositories/follow_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowState {
  final bool isFollowing;
  final int followers;
  final int followings;
  final bool isLoading;
  final bool hasMoreFollowers;
  final bool hasMoreFollowings;
  final int followerPage;
  final int followingPage;
  final List<FollowModel> followerList;
  final List<FollowModel> followingList;
  final String? error;
  final int? currentUserId;

  FollowState({
    required this.isFollowing,
    required this.followers,
    required this.followings,
    required this.isLoading,
    required this.hasMoreFollowers,
    required this.hasMoreFollowings,
    required this.followerPage,
    required this.followingPage,
    required this.followerList,
    required this.followingList,
    this.error,
    this.currentUserId,
  });

  FollowState copyWith({
    bool? isFollowing,
    int? followers,
    int? followings,
    bool? isLoading,
    bool? hasMoreFollowers,
    bool? hasMoreFollowings,
    int? followerPage,
    int? followingPage,
    List<FollowModel>? followerList,
    List<FollowModel>? followingList,
    String? error,
    int? currentUserId,
  }) {
    return FollowState(
      isFollowing: isFollowing ?? this.isFollowing,
      followers: followers ?? this.followers,
      followings: followings ?? this.followings,
      isLoading: isLoading ?? this.isLoading,
      hasMoreFollowers: hasMoreFollowers ?? this.hasMoreFollowers,
      hasMoreFollowings: hasMoreFollowings ?? this.hasMoreFollowings,
      followerPage: followerPage ?? this.followerPage,
      followingPage: followingPage ?? this.followingPage,
      followerList: followerList ?? this.followerList,
      followingList: followingList ?? this.followingList,
      error: error,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }

  factory FollowState.initial() => FollowState(
    isFollowing: false,
    followers: 0,
    followings: 0,
    isLoading: false,
    hasMoreFollowers: true,
    hasMoreFollowings: true,
    followerPage: 0,
    followingPage: 0,
    followerList: [],
    followingList: [],
    currentUserId: null,
  );
}

class FollowCubit extends Cubit<FollowState> {
  final FollowRepository followRepository = getIt<FollowRepository>();

  FollowCubit() : super(FollowState.initial());

  void _safeEmit(FollowState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  void resetListState() {
    _safeEmit(
      state.copyWith(
        followerList: [],
        followingList: [],
        followerPage: 0,
        followingPage: 0,
        hasMoreFollowers: true,
        hasMoreFollowings: true,
        error: null,
      ),
    );
  }

  // Load thông tin tổng quan
  Future<void> loadFollowData(int targetId) async {
    if (state.currentUserId != null && state.currentUserId != targetId) {
      resetListState();
    }
    _safeEmit(state.copyWith(isLoading: true, error: null));
    try {
      final isFollowing = await followRepository.checkFollow(targetId);
      final stats = await followRepository.getFollowStats(targetId);

      if (!isClosed) {
        _safeEmit(
          state.copyWith(
            isFollowing: isFollowing,
            followers: stats['followers'] ?? 0,
            followings: stats['followings'] ?? 0,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      _safeEmit(
        state.copyWith(isLoading: false, error: 'Không thể tải dữ liệu.'),
      );
    }
  }

  Future<void> toggleFollow(
    int targetId,
    int currentUserId, {
    FollowModel? targetUser,
    int? profileUserId,
  }) async {
    _safeEmit(state.copyWith(isLoading: true));

    try {
      final result = await followRepository.toggleFollow(targetId);
      final stats = await followRepository.getFollowStats(targetId);

      if (!isClosed) {
        List<FollowModel> updatedFollowers = List.from(state.followerList);
        List<FollowModel> updatedFollowings = List.from(state.followingList);

        if (targetUser != null) {
          // Cập nhật trong danh sách followers (Người theo dõi)
          updatedFollowers = state.followerList.map((user) {
            final idToCompare = user.followerId ?? user.followingId;
            if (idToCompare == targetUser.followerId ||
                idToCompare == targetUser.followingId) {
              return user.copyWith(isFollow: result);
            }
            return user;
          }).toList();

          // Cập nhật trong danh sách followings (Đang theo dõi)
          updatedFollowings = state.followingList.map((user) {
            final idToCompare = user.followingId ?? user.followerId;
            if (idToCompare == targetUser.followerId ||
                idToCompare == targetUser.followingId) {
              return user.copyWith(isFollow: result);
            }
            return user;
          }).toList();
        }

        final shouldUpdateIsFollowing =
            profileUserId != null && targetId == profileUserId;

        _safeEmit(
          state.copyWith(
            followerList: updatedFollowers,
            followingList: updatedFollowings,
            isFollowing: shouldUpdateIsFollowing ? result : state.isFollowing,
            followers: stats['followers'] ?? state.followers,
            followings: stats['followings'] ?? state.followings,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      _safeEmit(state.copyWith(isLoading: false, error: 'Thao tác thất bại.'));
    }
  }

  // Lazy load followers
  Future<void> fetchFollowers(int userId, {bool loadMore = false}) async {
    if (state.currentUserId != userId) {
      resetListState();
      _safeEmit(state.copyWith(currentUserId: userId));
    }
    if (state.isLoading || (loadMore && !state.hasMoreFollowers)) return;

    _safeEmit(state.copyWith(isLoading: true));
    final nextPage = loadMore ? state.followerPage + 1 : 1;

    try {
      final users = await followRepository.getFollowers(userId, nextPage, 10);
      final stats = await followRepository.getFollowStats(userId);

      _safeEmit(
        state.copyWith(
          isFollowing: isUserFollowing(userId),
          followerList: loadMore ? [...state.followerList, ...users] : users,
          followerPage: nextPage,
          hasMoreFollowers: users.length == 10,
          followers: stats['followers'] ?? state.followers,
          followings: stats['followings'] ?? state.followings,
          isLoading: false,
        ),
      );
    } catch (_) {
      _safeEmit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tải người theo dõi.',
        ),
      );
    }
  }

  // Lazy load followings
  Future<void> fetchFollowings(int userId, {bool loadMore = false}) async {
    if (state.currentUserId != userId) {
      resetListState();
      _safeEmit(state.copyWith(currentUserId: userId));
    }
    if (state.isLoading || (loadMore && !state.hasMoreFollowings)) return;

    _safeEmit(state.copyWith(isLoading: true));
    final nextPage = loadMore ? state.followingPage + 1 : 1;

    try {
      final users = await followRepository.getFollowings(userId, nextPage, 10);
      final stats = await followRepository.getFollowStats(userId);
      _safeEmit(
        state.copyWith(
          isFollowing: isUserFollowing(userId),
          followingList: loadMore ? [...state.followingList, ...users] : users,
          followingPage: nextPage,
          hasMoreFollowings: users.length == 10,
          followers: stats['followers'] ?? state.followers,
          followings: stats['followings'] ?? state.followings,
          isLoading: false,
        ),
      );
    } catch (_) {
      _safeEmit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tải danh sách đang theo dõi.',
        ),
      );
    }
  }

  bool isUserFollowing(int userId) {
    return state.followingList.any((user) => user.id == userId);
  }

  // Thêm method để clear error
  void clearError() {
    _safeEmit(state.copyWith(error: null));
  }
}
