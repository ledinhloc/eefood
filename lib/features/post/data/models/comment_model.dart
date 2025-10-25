import 'package:eefood/features/post/data/models/reaction_type.dart';

class CommentModel {
  final int? id;
  final int? userId;
  final int? parentId;
  final String content;
  final DateTime? createdAt;
  final List<CommentModel>? replies;
  final Map<ReactionType, int>? reactionCounts;
  final int? replyCount;
  final List<String>? images;
  final List<String>? videos;
  final String? username;
  final String? email;
  final String? avatarUrl;
  final int level;
  final bool isRepliesExpanded;
  final ReactionType? currentUserReaction;

  const CommentModel({
    this.id,
    this.userId,
    this.parentId,
    required this.content,
    this.createdAt,
    this.replies,
    this.reactionCounts,
    this.replyCount,
    this.images,
    this.videos,
    this.username,
    this.email,
    this.avatarUrl,
    this.level = 0,
    this.isRepliesExpanded = false,
    this.currentUserReaction,
  });

  factory CommentModel.fromJson(
    Map<String, dynamic> json, {
    int level = 0,
    bool isRepliesExpanded = false,
  }) {
    return CommentModel(
      id: json['id'],
      userId: json['userId'],
      parentId: json['parentId'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      replies: (json['replies'] as List?)
          ?.map((e) => CommentModel.fromJson(e, level: level + 1))
          .toList(),
      reactionCounts: (json['reactionCounts'] as Map?)?.map(
        (key, value) =>
            MapEntry(_reactionTypeFromString(key.toString()), value as int),
      ),
      replyCount: json['replyCount'] ?? 0,
      images: (json['images'] as List?)?.map((e) => e.toString()).toList(),
      videos: (json['videos'] as List?)?.map((e) => e.toString()).toList(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      level: level,
      isRepliesExpanded: isRepliesExpanded,
      currentUserReaction: json['currentUserReaction'] != null
          ? _reactionTypeFromString(json['currentUserReaction'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'parentId': parentId,
    'content': content,
    'createdAt': createdAt?.toIso8601String(),
    'replies': replies?.map((e) => e.toJson()).toList(),
    'reactionCounts': reactionCounts?.map((k, v) => MapEntry(k.name, v)),
    'replyCount': replyCount,
    'images': images,
    'videos': videos,
    'username': username,
    'email': email,
    'avatarUrl': avatarUrl,
    'currentUserReaction': currentUserReaction?.name,
  };

  static ReactionType _reactionTypeFromString(String key) {
    return ReactionType.values.firstWhere(
      (e) => e.name.toLowerCase() == key.toLowerCase(),
      orElse: () => ReactionType.LIKE,
    );
  }

  CommentModel copyWith({
    int? id,
    int? userId,
    int? parentId,
    String? content,
    DateTime? createdAt,
    List<CommentModel>? replies,
    Map<ReactionType, int>? reactionCounts,
    int? replyCount,
    List<String>? images,
    List<String>? videos,
    String? username,
    String? email,
    String? avatarUrl,
    int? level,
    bool? isRepliesExpanded,
    Object? currentUserReaction = _noChange, 
  }) {
    return CommentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      replyCount: replyCount ?? this.replyCount,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      username: username ?? this.username,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      isRepliesExpanded: isRepliesExpanded ?? this.isRepliesExpanded,
      currentUserReaction: currentUserReaction == _noChange
          ? this.currentUserReaction
          : currentUserReaction as ReactionType?,
    );
  }

  static const _noChange = Object(); 
}
