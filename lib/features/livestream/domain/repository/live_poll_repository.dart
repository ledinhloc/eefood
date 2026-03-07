import '../../data/model/live_poll_response.dart';
import '../../data/model/poll_result_response.dart';
import '../../data/model/create_live_poll_request.dart';

abstract class LivePollRepository {
  Future<LivePollResponse> getActivePoll({
    required int liveStreamId
  });

  Future<LivePollResponse> createPoll({
    required int liveStreamId,
    required CreateLivePollRequest request,
  });

  Future<LivePollResponse> getPollDetail({
    required int liveStreamId,
    required String pollId,
  });

  Future<LivePollResponse> openPoll({
    required int liveStreamId,
    required String pollId,
  });

  Future<LivePollResponse> closePoll({
    required int liveStreamId,
    required String pollId,
  });

  Future<PollResultResponse> vote({
    required int liveStreamId,
    required String pollId,
    required List<int> optionIds,
  });

  Future<PollResultResponse> getPollResult({
    required int liveStreamId,
    required String pollId,
  });
}