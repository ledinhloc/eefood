
// State
import 'package:equatable/equatable.dart';

import '../../data/model/live_reaction_response.dart';

class LiveReactionState extends Equatable {
  final List<LiveReactionResponse> reactions;
  final bool isLoading;
  final String? error;

  const LiveReactionState({
    this.reactions = const [],
    this.isLoading = false,
    this.error,
  });

  LiveReactionState copyWith({
    List<LiveReactionResponse>? reactions,
    bool? isLoading,
    String? error,
  }) {
    return LiveReactionState(
      reactions: reactions ?? this.reactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [reactions, isLoading, error];
}
