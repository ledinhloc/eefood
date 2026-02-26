import 'package:equatable/equatable.dart';
import 'package:eefood/features/livestream/data/model/block_user_response.dart';

class BlockUserState extends Equatable {
  final bool loading;
  final List<BlockUserResponse> users;
  final String? error;

  const BlockUserState({
    this.loading = false,
    this.users = const [],
    this.error,
  });

  BlockUserState copyWith({
    bool? loading,
    List<BlockUserResponse>? users,
    String? error,
  }) {
    return BlockUserState(
      loading: loading ?? this.loading,
      users: users ?? this.users,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, users, error];
}