// data/repository/live_viewer_repository_impl.dart
import 'package:dio/dio.dart';
import '../../domain/repository/live_viewer_repository.dart';
import '../model/viewer_model.dart';

class LiveViewerRepositoryImpl extends LiveViewerRepository {
  final Dio dio;

  LiveViewerRepositoryImpl({required this.dio});

  @override
  Future<void> joinLiveStream(int liveStreamId) async {
    await dio.post(
      '/v1/livestreams/$liveStreamId/viewers/join',
    );
  }

  @override
  Future<void> leaveLiveStream(int liveStreamId) async {
    await dio.post(
      '/v1/livestreams/$liveStreamId/viewers/leave',
    );
  }

  @override
  Future<List<ViewerModel>> getViewers(int liveStreamId) async {
    final res = await dio.get(
      '/v1/livestreams/$liveStreamId/viewers',
    );

    final data = res.data['data'] as List;
    return data
        .map((json) => ViewerModel.fromJson(json))
        .toList();
  }
}