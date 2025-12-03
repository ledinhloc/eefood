class StoryCollectionModel {
  final int? id;
  final int userId;
  final String name;
  final String imageUrl;
  final String description;

  StoryCollectionModel({
    this.id,
    required this.userId,
    required this.name,
    required this.imageUrl,
    required this.description,
  });

  StoryCollectionModel copyWith({
    int? id,
    int? userId,
    String? name,
    String? imageUrl,
    String? description
  }) {
    return StoryCollectionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId, 
      name: name ?? this.name, 
      imageUrl: imageUrl ?? this.imageUrl, 
      description: description ?? this.description
    );
  }

  factory StoryCollectionModel.fromJson(Map<String, dynamic> json) {
    return StoryCollectionModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description']
    );
  }
}

class StoryCollectionPageModel {
  final List<StoryCollectionModel> collections;
  final int totalElements;
  final int numberOfElements;

  StoryCollectionPageModel({
    required this.collections,
    required this.totalElements,
    required this.numberOfElements
  });

  factory StoryCollectionPageModel.fromJson(Map<String, dynamic> json) {
    return StoryCollectionPageModel(
      numberOfElements: json['numberOfElements'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      collections: (json['content'] as List<dynamic>? ?? [])
          .map((e) => StoryCollectionModel.fromJson(e))
          .toList(),
    );
  }
}
