class NotificationSettings {
  final int id;
  final String? type;
  final bool? enabled;

  const NotificationSettings({
    required this.id,
    this.type,
    this.enabled
  });
}