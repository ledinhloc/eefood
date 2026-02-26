
import 'package:equatable/equatable.dart';

class ViewerModel extends Equatable {
  final int userId;
  final String username;
  final String? avatarUrl;
  final DateTime joinedAt;

  const ViewerModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.joinedAt,
  });

  factory ViewerModel.fromJson(Map<String, dynamic> json) {
    return ViewerModel(
      userId: json['userId'] as int,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [userId, username, avatarUrl, joinedAt];
}