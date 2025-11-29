import '../../data/model/live_reaction_response.dart';

abstract class LiveReactionRepository {
  Future<List<LiveReactionResponse>> getReactions(int liveStreamId);

  Future<LiveReactionResponse> createReaction(int liveStreamId, String emotion);
}
