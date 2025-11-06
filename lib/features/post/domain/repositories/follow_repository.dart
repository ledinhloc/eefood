import 'package:eefood/features/auth/data/models/UserModel.dart';
import 'package:eefood/features/post/data/models/follow_model.dart';

abstract class FollowRepository {
  Future<bool> toggleFollow(int targetId);
  Future<bool> checkFollow(int targetId);
  Future<List<FollowModel>> getFollowers(int userId, int page, int size);
  Future<List<FollowModel>> getFollowings(int userId, int page, int size);
  Future<Map<String, int>> getFollowStats(int userId);
}