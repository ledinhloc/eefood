enum StoryMode { FOLLOWING_ONLY, PRIVATE, CUSTOM_INCLUDE, BLACKLIST }

class StorySettingModel {
  final int? id;
  final int userId;
  final StoryMode mode;
  final List<int>? allowedUserIds;
  final List<int>? blockedUserIds;

  StorySettingModel({
    this.id,
    required this.userId,
    required this.mode,
    this.allowedUserIds,
    this.blockedUserIds,
  });

  factory StorySettingModel.fromJson(Map<String, dynamic> json) {
    return StorySettingModel(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      userId: (json['userId'] as num).toInt(),
      mode: StoryMode.values.firstWhere(
        (e) => e.toString() == 'StoryMode.${json['mode']}',
        orElse: () => StoryMode.PRIVATE,
      ),
      allowedUserIds: json['allowedUserIds'] != null
          ? List<int>.from(
              json['allowedUserIds'].map((e) => (e as num).toInt()),
            )
          : null,
      blockedUserIds: json['blockedUserIds'] != null
          ? List<int>.from(
              json['blockedUserIds'].map((e) => (e as num).toInt()),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'mode': mode.toString().split('.').last,
      'allowedUserIds': allowedUserIds,
      'blockedUserIds': blockedUserIds,
    };
  }
}
