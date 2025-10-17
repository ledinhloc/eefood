class PostSimpleModel {
  final int id;
  final int recipeId;
  final String title;
  final String? imageUrl;
  final DateTime createdAt;


  PostSimpleModel({
    required this.id,
    required this.recipeId,
    required this.title,
    required this.createdAt,
    this.imageUrl,
  });

  factory PostSimpleModel.fromJson(Map<String, dynamic> json) {
    return PostSimpleModel(
      id: json['id'] as int,
      recipeId: json['recipeId'] as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.fromMillisecondsSinceEpoch(0),
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
