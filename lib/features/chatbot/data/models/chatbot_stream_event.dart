import 'package:eefood/features/chatbot/data/models/chatbot_response.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chatbot_stream_event.g.dart';

enum ChatbotEventType {status, message, data, error, complete }

@JsonSerializable()
class ChatbotStreamEvent {
  final ChatbotEventType type;
  final String? message;
  final ChatbotResponse? data;

  ChatbotStreamEvent({
    required this.type,
    required this.message,
    required this.data,
  });

  factory ChatbotStreamEvent.fromJson(Map<String, dynamic> json) =>
      _$ChatbotStreamEventFromJson(json);
  Map<String, dynamic> toJson() => _$ChatbotStreamEventToJson(this);
}
