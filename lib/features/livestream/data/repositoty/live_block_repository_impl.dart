import 'package:dio/dio.dart';
import '../model/block_user_response.dart';
import '../../domain/repository/live_block_repository.dart';

class LiveBlockRepositoryImpl extends LiveBlockRepository {
  final Dio dio;
  LiveBlockRepositoryImpl({required this.dio});

  @override
  Future<List<BlockUserResponse>> getBlockedUsers() async {
    final res = await dio.get('/v1/livestreams/block');

    final data = res.data['data'] as List;
    return data
        .map((json) => BlockUserResponse.fromJson(json))
        .toList();
  }

  @override
  Future<BlockUserResponse> blockUser(int blockedUserId) async {
    final res = await dio.post(
      '/v1/livestreams/block',
      queryParameters: {'blockedUserId': blockedUserId},
    );

    return BlockUserResponse.fromJson(res.data['data']);
  }

  @override
  Future<void> unblockUser(int blockedUserId) async {
    await dio.delete(
      '/v1/livestreams/block',
      queryParameters: {'blockedUserId': blockedUserId},
    );
  }


  // @override
  // Future<UserInfo> searchUser(String keyword) async {
  //   final res = await dio.get(
  //     "/v1/users/search",
  //     queryParameters: {"keyword": keyword},
  //   );
  //
  //   return UserInfo.fromJson(res.data["data"]);
  // }
}