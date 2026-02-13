// presentation/provider/live_viewer_state.dart
import 'package:equatable/equatable.dart';
import '../../data/model/viewer_model.dart';

class LiveViewerState extends Equatable {
  final List<ViewerModel> viewers;
  final bool loading;
  final String? error;
  final bool isJoined;

  const LiveViewerState({
    this.viewers = const [],
    this.loading = false,
    this.error,
    this.isJoined = false,
  });

  LiveViewerState copyWith({
    List<ViewerModel>? viewers,
    bool? loading,
    String? error,
    bool? isJoined,
  }) {
    return LiveViewerState(
      viewers: viewers ?? this.viewers,
      loading: loading ?? this.loading,
      error: error,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  static LiveViewerState initial() => const LiveViewerState();

  @override
  List<Object?> get props => [viewers, loading, error, isJoined];
}