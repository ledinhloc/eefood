import '../../data/model/live_stream_response.dart';

abstract class LiveRepository{
  Future<LiveStreamResponse> startLiveStream(String description);
  Future<LiveStreamResponse> endLiveStream(int liveStreamId);
  Future<LiveStreamResponse> getLiveStream(int liveStreamId);
  Future<LiveStreamResponse> checkUserStream(int userId);
}