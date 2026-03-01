import 'package:json_annotation/json_annotation.dart';

part 'chatbot_response.g.dart';

@JsonSerializable()
class ChatbotResponse {
  final int? id;
  final String? message;
  final String role;
  final List<dynamic>? data;
  final Map<String, dynamic>? meta;
  final bool? isStatusMessage;

  ChatbotResponse({
    this.id,
    this.message,
    required this.role,
    this.data,
    this.meta,
    this.isStatusMessage,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatbotResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatbotResponseToJson(this);
}
