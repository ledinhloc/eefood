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
}
