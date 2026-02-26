// data/model/viewer_update_message.dart
import 'viewer_model.dart';

class ViewerUpdateMessage {
  final String type; // "JOIN" hoặc "LEAVE"
  final ViewerModel? viewer; // null nếu type = "LEAVE"
  final int? userId; // Chỉ có khi type = "LEAVE"

  const ViewerUpdateMessage({
    required this.type,
    this.viewer,
    this.userId,
  });

  factory ViewerUpdateMessage.fromJson(Map<String, dynamic> json) {
    return ViewerUpdateMessage(
      type: json['type'] as String,
      viewer: json['viewer'] != null
          ? ViewerModel.fromJson(json['viewer'] as Map<String, dynamic>)
          : null,
      userId: json['userId'] as int?,
    );
  }
}