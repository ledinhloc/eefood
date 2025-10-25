class PostCollectionModel {
  final int id;
  final int postId;
  final int userId;
  final int recipeId;
  final String title;
  final String? imageUrl;
  final DateTime createdAt;
  final String username;
  final String email;
  final String? avatarUrl;

  PostCollectionModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.recipeId,
    required this.title,
    this.imageUrl,
    required this.createdAt,
    required this.username,
    required this.email,
    this.avatarUrl,
  });

  factory PostCollectionModel.fromJson(Map<String, dynamic> json) {
    return PostCollectionModel(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      recipeId: json['recipeId'],
      title: json['title'],
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'],
    );
  }
}