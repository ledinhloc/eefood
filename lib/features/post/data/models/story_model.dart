class StoryModel {
  final int? id;
  final int userId;
  final String? type;
  final String? contentUrl;
  final DateTime? createdAt;
  final DateTime? expiredAt;

  final String? username;
  final String? email;
  final String? avatarUrl;

  final bool? isViewed;

  StoryModel({
    this.id,
    required this.userId,
    this.type,
    this.contentUrl,
    this.createdAt,
    this.expiredAt,
    this.username,
    this.email,
    this.avatarUrl,
    this.isViewed,
  });

  StoryModel copyWith({bool? isViewed}) {
    return StoryModel(
      id: id,
      userId: userId,
      type: type,
      contentUrl: contentUrl,
      createdAt: createdAt,
      expiredAt: expiredAt,
      username: username,
      email: email,
      avatarUrl: avatarUrl,
      isViewed: isViewed ?? this.isViewed,
    );
  }

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['id'],
      userId: json['userId'],
      type: json['type'],
      contentUrl: json['contentUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      expiredAt: json['expiredAt'] != null
          ? DateTime.parse(json['expiredAt'])
          : null,
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
      isViewed: json['viewed'],
    );
  }
}
