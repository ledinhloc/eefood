class FollowModel {
  final int id;
  final int followerId;
  final int followingId;
  final DateTime? createdAt;

  final String? username;
  final String? email;
  final String? avatarUrl;
  FollowModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    this.createdAt,
    this.username,
    this.avatarUrl,
    this.email,
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
    );
  }
}
