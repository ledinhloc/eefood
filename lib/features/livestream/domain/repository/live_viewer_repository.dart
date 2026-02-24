
import '../../data/model/viewer_model.dart';

abstract class LiveViewerRepository {
  Future<void> joinLiveStream(int liveStreamId);
  Future<void> leaveLiveStream(int liveStreamId);
  Future<List<ViewerModel>> getViewers(int liveStreamId);
}