class SimilarPostModel {
  final int? postId;
  final int? recipeId;
  final String title;
  final String? imageUrl;
  final List<String> matchedIngredients;

  const SimilarPostModel({
    this.postId,
    this.recipeId,
    required this.title,
    this.imageUrl,
    this.matchedIngredients = const [],
  });

  factory SimilarPostModel.fromJson(Map<String, dynamic> json) {
    return SimilarPostModel(
      postId: (json['postId'] as num?)?.toInt(),
      recipeId: (json['recipeId'] as num?)?.toInt(),
      title: json['title'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      matchedIngredients: (json['matchedIngredients'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}
