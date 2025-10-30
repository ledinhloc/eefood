class PostPublishModel {
  final int id;
  final int recipeId;
  final int userId;
  final String title;
  final String content;
  final String? imageUrl;
  final DateTime? createdAt;

  // Các thông tin hiển thị
  final String? difficulty;
  final String? location;
  final String? prepTime;
  final String? cookTime;
  final int? countReaction;
  final int? countComment;

  PostPublishModel({
    required this.id,
    required this.recipeId,
    required this.userId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.createdAt,
    this.difficulty,
    this.location,
    this.prepTime,
    this.cookTime,
    this.countReaction,
    this.countComment,
  });

  factory PostPublishModel.fromJson(Map<String, dynamic> json) => PostPublishModel(
    id: json['id'],
    recipeId: json['recipeId'],
    userId: json['userId'],
    title: json['title'] ?? '',
    content: json['content'] ?? '',
    imageUrl: json['imageUrl'],
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'])
        : null,
    difficulty: json['difficulty'],
    location: json['location'],
    prepTime: json['prepTime'],
    cookTime: json['cookTime'],
    countReaction: json['countReaction'],
    countComment: json['countComment'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipeId': recipeId,
    'userId': userId,
    'title': title,
    'content': content,
    'imageUrl': imageUrl,
    'createdAt': createdAt?.toIso8601String(),
    'difficulty': difficulty,
    'location': location,
    'prepTime': prepTime,
    'cookTime': cookTime,
    'countReaction': countReaction,
    'countComment': countComment,
  };
}