class Notification {
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
  const Notification({
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
}
