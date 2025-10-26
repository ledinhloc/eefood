class ShareModel {
  final int? id;
  final int? postId;
  final int? userId;
  final String? content;
  final String? platform;
  final String? imageUrl;
  ShareModel({
    this.id,
    this.postId,
    this.userId,
    this.content,
    this.platform,
    this.imageUrl,
  });

  factory ShareModel.fromJson(Map<String, dynamic> json) {
    return ShareModel(
      id: json['id'] ?? 0,
      postId: json['postId'],
      userId: json['userId'],
      content: json['content'] ?? '',
      platform: json['platform'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'userId': userId,
    'content': content,
    'platform': platform,
    'imageUrl': imageUrl,
  };
}
