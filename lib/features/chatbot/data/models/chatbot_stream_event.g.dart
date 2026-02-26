// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_stream_event.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatbotStreamEvent _$ChatbotStreamEventFromJson(Map<String, dynamic> json) =>
    ChatbotStreamEvent(
      type: $enumDecode(_$ChatbotEventTypeEnumMap, json['type']),
      message: json['message'] as String?,
      data: json['payload'] == null
          ? null
          : ChatbotResponse.fromJson(json['payload'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ChatbotStreamEventToJson(ChatbotStreamEvent instance) =>
    <String, dynamic>{
      'type': _$ChatbotEventTypeEnumMap[instance.type]!,
      'message': instance.message,
      'payload': instance.data,
    };

const _$ChatbotEventTypeEnumMap = {
  ChatbotEventType.status: 'status',
  ChatbotEventType.message: 'message',
  ChatbotEventType.data: 'data',
  ChatbotEventType.error: 'error',
  ChatbotEventType.complete: 'complete',
};
