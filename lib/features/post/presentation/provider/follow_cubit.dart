import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/follow_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eefood/features/post/domain/repositories/follow_repository.dart';

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
  );
}

class FollowCubit extends Cubit<FollowState> {
  final FollowRepository followRepository = getIt<FollowRepository>();

  FollowCubit() : super(FollowState.initial());

  // Load thông tin tổng quan
  Future<void> loadFollowData(int targetId) async {
    if (isClosed) return; // Thêm kiểm tra này

    emit(state.copyWith(isLoading: true, error: null));
    try {
      final isFollowing = await followRepository.checkFollow(targetId);
      final stats = await followRepository.getFollowStats(targetId);

      if (!isClosed) {
        // Kiểm tra trước khi emit
        emit(
          state.copyWith(
            isFollowing: isFollowing,
            followers: stats['followers'] ?? 0,
            followings: stats['followings'] ?? 0,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: 'Không thể tải dữ liệu.'));
      }
    }
  }

  Future<void> toggleFollow(int targetId) async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true));
    try {
      final result = await followRepository.toggleFollow(targetId);
      final stats = await followRepository.getFollowStats(targetId);

      if (!isClosed) {
        emit(
          state.copyWith(
            isFollowing: result,
            followers: stats['followers'] ?? 0,
            followings: stats['followings'] ?? 0,
            followerList: state.followerList
                .where((u) => u.id != targetId)
                .toList(),
            followingList: result
                ? [
                    ...state.followingList,
                    FollowModel(
                      id: targetId,
                      followerId: 0,
                      followingId: targetId,
                    ),
                  ]
                : state.followingList.where((u) => u.id != targetId).toList(),
            isLoading: false,
          ),
        );
      }
    } catch (_) {
      if (!isClosed) {
        emit(state.copyWith(isLoading: false, error: 'Thao tác thất bại.'));
      }
    }
  }

  // Lazy load followers
  Future<void> fetchFollowers(int userId, {bool loadMore = false}) async {
    if (state.isLoading || (loadMore && !state.hasMoreFollowers)) return;

    emit(state.copyWith(isLoading: true));
    final nextPage = loadMore ? state.followerPage + 1 : 1;

    try {
      final users = await followRepository.getFollowers(userId, nextPage, 10);
      print('Chiều dài: ${users.length}');
      emit(
        state.copyWith(
          followerList: loadMore ? [...state.followerList, ...users] : users,
          followerPage: nextPage,
          hasMoreFollowers: users.length == 10,
          isLoading: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tải người theo dõi.',
        ),
      );
    }
  }

  // Lazy load followings
  Future<void> fetchFollowings(int userId, {bool loadMore = false}) async {
    if (state.isLoading || (loadMore && !state.hasMoreFollowings)) return;

    emit(state.copyWith(isLoading: true));
    final nextPage = loadMore ? state.followingPage + 1 : 1;

    try {
      final users = await followRepository.getFollowings(userId, nextPage, 10);
      emit(
        state.copyWith(
          followingList: loadMore ? [...state.followingList, ...users] : users,
          followingPage: nextPage,
          hasMoreFollowings: users.length == 10,
          isLoading: false,
        ),
      );
    } catch (_) {
      emit(
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
}
