class PostModel {
  final int id;
  final int recipeId;
  final int userId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime? createdAt;

  PostModel({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
    id: json['id'],
    recipeId: json['recipeId'],
    userId: json['userId'],
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    imageUrl: json['imageUrl'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipeId': recipeId,
    'userId': userId,
    'title': title,
    'content': content,
    'imageUrl': imageUrl,
  };
}
