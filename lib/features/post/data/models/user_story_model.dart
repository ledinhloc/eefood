import 'story_model.dart';

class UserStoryModel {
  final int userId;
  final String? username;
  final String? avatarUrl;
  final List<StoryModel> stories;

  UserStoryModel({
    required this.userId,
    this.username,
    this.avatarUrl,
    required this.stories,
  });

  UserStoryModel copyWith({
    int? userId,
    String? username,
    String? avatarUrl,
    List<StoryModel>? stories,
  }) {
    return UserStoryModel(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      stories: stories ?? this.stories,
    );
  }

  factory UserStoryModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> storyList = json['stories'] ?? [];

    return UserStoryModel(
      userId: json['userId'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      stories: storyList.map((s) => StoryModel.fromJson(s)).toList(),
    );
  }
}
