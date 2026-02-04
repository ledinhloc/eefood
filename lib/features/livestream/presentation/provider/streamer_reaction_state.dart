
import 'package:equatable/equatable.dart';

import '../../data/model/live_reaction_response.dart';

class StreamerReactionState extends Equatable {
  final List<LiveReactionResponse> reactions;
  final bool isLoading;
  final String? error;

  const StreamerReactionState({
    this.reactions = const [],
    this.isLoading = false,
    this.error,
  });

  StreamerReactionState copyWith({
    List<LiveReactionResponse>? reactions,
    bool? isLoading,
    String? error,
  }) {
    return StreamerReactionState(
      reactions: reactions ?? this.reactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [reactions, isLoading, error];
}
