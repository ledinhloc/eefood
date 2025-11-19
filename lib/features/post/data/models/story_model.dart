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

  StoryModel copyWith({
    int? id,
    int? userId,
    String? type,
    String? contentUrl,
    DateTime? createdAt,
    DateTime? expiredAt,
    String? username,
    String? email,
    String? avatarUrl,
    bool? isViewed,
  }) {
    return StoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      contentUrl: contentUrl ?? this.contentUrl,
      createdAt: createdAt ?? this.createdAt,
      expiredAt: expiredAt ?? this.expiredAt,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
