import 'story_model.dart';

class UserStoryModel {
  final int userId;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final List<StoryModel> stories;

  UserStoryModel({
    required this.userId,
    this.username,
    this.email,
    this.avatarUrl,
    required this.stories,
  });

  UserStoryModel copyWith({
    int? userId,
    String? username,
    String? email,
    String? avatarUrl,
    List<StoryModel>? stories,
  }) {
    return UserStoryModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      stories: stories ?? this.stories,
    );
  }

  factory UserStoryModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> storyList = json['stories'] ?? [];

    return UserStoryModel(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      stories: storyList.map((s) => StoryModel.fromJson(s)).toList(),
    );
  }
}
