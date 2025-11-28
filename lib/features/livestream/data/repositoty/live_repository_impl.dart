import 'package:dio/dio.dart';
import 'package:eefood/features/livestream/data/model/live_stream_response.dart';
import 'package:eefood/features/livestream/domain/repository/live_repository.dart';

class LiveRepositoryImpl extends LiveRepository{
  final Dio dio;

  LiveRepositoryImpl({required this.dio});

  @override
  Future<LiveStreamResponse> checkUserStream(int userId) async {
    final res = await dio.get(
      '/v1/livestreams/check',
      queryParameters: {
        'userId': userId
      },
    );
    return LiveStreamResponse.fromJson(res.data['data']);
  }

  @override
  Future<LiveStreamResponse> startLiveStream(String description) async {
    final res = await dio.post(
      '/v1/livestreams/start',
      queryParameters: {
        'description': description
      },
    );
    return LiveStreamResponse.fromJson(res.data['data']);
  }

  @override
  Future<LiveStreamResponse> endLiveStream(int liveStreamId) async {
    final res = await dio.post(
      '/v1/livestreams/$liveStreamId/end'
    );

    return LiveStreamResponse.fromJson(res.data['data']);
  }

  Future<LiveStreamResponse> getLiveStream(int liveStreamId) async{
    final res = await dio.get(
      '/v1/livestreams/$liveStreamId'
    );
    return LiveStreamResponse.fromJson(res.data['data']);
  }
}