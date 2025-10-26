import 'package:dio/dio.dart';
import 'package:eefood/features/post/data/models/share_model.dart';
import 'package:eefood/features/post/domain/repositories/share_repository.dart';

class ShareRepositoryImpl extends ShareRepository {
  final Dio dio;
  ShareRepositoryImpl({required this.dio});

  @override
  Future<ShareModel?> sharePost(ShareModel share) async {
    final response = await dio.post(
      '/v1/shares',
      data: {
        'postId': share.postId,
        'userId': share.userId,
        'platform': share.platform,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>;
    return ShareModel.fromJson(data);
  }

  @override
  Future<int> countShareByPost(int postId) async {
    final response = await dio.get(
      '/v1/shares/count/$postId'
    );

    final data = response.data['data'] as int;
    return data;
  }
}
