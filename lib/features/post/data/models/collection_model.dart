
import 'package:eefood/features/post/data/models/post_collection_model.dart';

class CollectionModel {
  final int id;
  final String name;
  final String? coverImageUrl;
  final DateTime? updatedAt;
  final List<PostCollectionModel>? posts;

  CollectionModel({
    required this.id,
    required this.name,
    this.coverImageUrl,
    this.updatedAt,
    this.posts,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'],
      name: json['name'],
      coverImageUrl: json['coverImageUrl'],
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      posts: json['posts'] != null
          ? (json['posts'] as List)
          .map((e) => PostCollectionModel.fromJson(e))
          .toList()
          : [],
    );
  }
}
