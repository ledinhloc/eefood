class NotificationModel {
  final int id;
  final String? title;
  final String? body;
  final String? path;
  final String? avatarUrl;
  final String? postImageUrl;
  final String type;
  final int? userId;
  final bool? isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  NotificationModel({
    required this.id,
    this.title,
    this.body,
    this.path,
    this.avatarUrl,
    this.postImageUrl,
    required this.type,
    this.userId,
    this.isRead,
    this.readAt,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      path: json['path'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      postImageUrl: json['postImageUrl'] ?? '',
      type: json['type'] ?? '',
      isRead: json['read'] ?? false,
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
