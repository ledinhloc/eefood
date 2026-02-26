// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatbotResponse _$ChatbotResponseFromJson(Map<String, dynamic> json) =>
    ChatbotResponse(
      message: json['message'] as String?,
      role: json['role'] as String,
      data: json['data'] as List<dynamic>?,
      meta: json['meta'] as Map<String, dynamic>?,
      isStatusMessage: json['isStatusMessage'] as bool?,
    );

Map<String, dynamic> _$ChatbotResponseToJson(ChatbotResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'role': instance.role,
      'data': instance.data,
      'meta': instance.meta,
    };
