import 'package:dio/dio.dart';
import 'package:eefood/features/livestream/data/model/live_poll_option_voters_response.dart';
import 'package:eefood/features/livestream/domain/enum/poll_status.dart';

import '../../domain/repository/live_poll_repository.dart';
import '../model/create_live_poll_request.dart';
import '../model/live_poll_response.dart';
import '../model/poll_result_response.dart';

class LivePollRepositoryImpl extends LivePollRepository {
  final Dio dio;

  LivePollRepositoryImpl({required this.dio});

  @override
  Future<PollOptionVotersResponse?> getOptionVoters({
    required int liveStreamId,
    required int pollId,
    required int optionId
  }) async {
    final res = await dio.get(
      '/v1/livestreams/$liveStreamId/polls/$pollId/options/$optionId/voters'
    );
    final data = res.data['data'];
    if (data == null) return null;

    return PollOptionVotersResponse.fromJson(data);
  }

  @override
  Future<LivePollResponse?> getActivePoll({
    required int liveStreamId
  }) async {
    final res = await dio.get(
      '/v1/livestreams/$liveStreamId/polls/active'
    );
    final data = res.data['data'];
    if (data == null) return null;

    return LivePollResponse.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<LivePollResponse> createPoll({
    required int liveStreamId,
    required CreateLivePollRequest request,
  }) async {
    final res = await dio.post(
      '/v1/livestreams/$liveStreamId/polls',
      data: request.toJson(),
    );

    return LivePollResponse.fromJson(res.data['data']);
  }

  @override
  Future<LivePollResponse> getPollDetail({
    required int liveStreamId,
    required int pollId,
  }) async {
    final res = await dio.get(
      '/v1/livestreams/$liveStreamId/polls/$pollId',
    );

    return LivePollResponse.fromJson(res.data['data']);
  }

  Future<LivePollResponse> updatePollStatus({
    required int liveStreamId,
    required int pollId,
    required PollStatus pollStatus,
  }) async {
    final res = await dio.patch(
      '/v1/livestreams/$liveStreamId/polls/$pollId/status',
      queryParameters: {
        'pollStatus': pollStatus.name.toUpperCase(),
      },
    );

    return LivePollResponse.fromJson(res.data['data']);
  }

  @override
  Future<LivePollResponse> openPoll({
    required int liveStreamId,
    required int pollId,
  }) async {
    return updatePollStatus(
      liveStreamId: liveStreamId,
      pollId: pollId,
      pollStatus: PollStatus.open,
    );
  }

  @override
  Future<LivePollResponse> closePoll({
    required int liveStreamId,
    required int pollId,
  }) async {
    return updatePollStatus(
      liveStreamId: liveStreamId,
      pollId: pollId,
      pollStatus: PollStatus.closed,
    );
  }

  @override
  Future<PollResultResponse> vote({
    required int liveStreamId,
    required int pollId,
    required List<int> optionIds,
  }) async {
    final res = await dio.post(
      '/v1/livestreams/$liveStreamId/polls/$pollId/vote',
      queryParameters: {
        'optionIds': optionIds,
      },
    );

    return PollResultResponse.fromJson(res.data['data']);
  }

  @override
  Future<PollResultResponse> getPollResult({
    required int liveStreamId,
    required int pollId,
  }) async {
    final res = await dio.get(
      '/v1/livestreams/$liveStreamId/polls/$pollId/result',
    );

    return PollResultResponse.fromJson(res.data['data']);
  }
}