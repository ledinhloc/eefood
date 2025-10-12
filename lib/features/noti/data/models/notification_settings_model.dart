class NotificationSettingsModel {
  final int id;
  final String? type;
  final bool? enabled;
  NotificationSettingsModel({
    required this.id,
    this.type,
    this.enabled,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return NotificationSettingsModel(
      id: json['id'],
      type: json['type'] ?? '',
      enabled: json['enabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'enabled': enabled,
      };

  NotificationSettingsModel copyWith({bool? enabled}) {
    return NotificationSettingsModel(
      id: id,
      type: type,
      enabled: enabled ?? this.enabled,
    );
  }
}
