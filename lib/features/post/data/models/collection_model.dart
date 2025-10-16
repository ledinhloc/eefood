
import 'package:eefood/features/post/data/models/post_simple_model.dart';

class CollectionModel {
  final int id;
  final String name;
  final String? coverImageUrl;
  final DateTime? createdAt;
  final List<PostSimpleModel>? posts;

  CollectionModel({
    required this.id,
    required this.name,
    this.coverImageUrl,
    this.createdAt,
    this.posts,
  });

  factory CollectionModel.fromJson(Map<String, dynamic> json) {
    return CollectionModel(
      id: json['id'],
      name: json['name'],
      coverImageUrl: json['coverImageUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      posts: json['posts'] != null
          ? (json['posts'] as List)
          .map((e) => PostSimpleModel.fromJson(e))
          .toList()
          : [],
    );
  }
}
