class PostSimpleModel {
  final int id;
  final int recipeId;
  final String title;
  final String? imageUrl;

  PostSimpleModel({
    required this.id,
    required this.recipeId,
    required this.title,
    this.imageUrl,
  });

  factory PostSimpleModel.fromJson(Map<String, dynamic> json) {
    return PostSimpleModel(
      id: json['id'] as int,
      recipeId: json['recipeId'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
