class FollowModel {
  final int? id;
  final int followerId;
  final int followingId;
  final DateTime? createdAt;

  final String? username;
  final String? email;
  final String? avatarUrl;
  final bool? isFollow;
  FollowModel({
    this.id,
    required this.followerId,
    required this.followingId,
    this.createdAt,
    this.username,
    this.avatarUrl,
    this.email,
    this.isFollow,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id'],
      followerId: json['followerId'],
      followingId: json['followingId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      username: json['username'],
      avatarUrl: json['avatarUrl'],
      email: json['email'],
      isFollow: json['follow'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'followerId': followerId,
      'followingId': followingId,
      'createdAt': createdAt?.toIso8601String(),
      'username': username,
      'avatarUrl': avatarUrl,
      'email': email,
      'follow': isFollow,
    };
  }

  FollowModel copyWith({
    int? id,
    int? followerId,
    int? followingId,
    DateTime? createdAt,
    String? username,
    String? email,
    String? avatarUrl,
    bool? isFollow,
  }) {
    return FollowModel(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isFollow: isFollow ?? this.isFollow,
    );
  }
}
