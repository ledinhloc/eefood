import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:eefood/features/chatbot/data/models/chatbot_request.dart';
import 'package:eefood/features/chatbot/data/models/chatbot_response.dart';
import 'package:eefood/features/chatbot/data/models/chatbot_stream_event.dart';
import 'package:eefood/features/chatbot/data/models/enum/chat_role.dart';
import 'package:eefood/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:eefood/features/post/data/models/post_model.dart';

class ChatbotRepositoryImpl extends ChatbotRepository {
  final Dio dio;
  ChatbotRepositoryImpl({required this.dio});

  @override
  Future<void> deleteChatMessage(int id) async {
    try {
      await dio.delete('/v1/chatbot/$id');
    } catch (e) {
      throw Exception("Failed to delete  $e");
    }
  }

  @override
  Future<List<PostModel>> getRecentPostsFromHistory() async {
    try {
      final response = await dio.get('/v1/chatbot/recent-data');

      if (response.statusCode != 200) {
        return List.empty();
      }
      final data = response.data;
      final List<dynamic> listPost = data['data'] ?? [];
      return listPost
          .map<PostModel>((json) => PostModel.fromJson(json))
          .toList();
    } catch (err) {
      throw Exception("Failed to get post $err");
    }
  }

  @override
  Future<List<ChatbotResponse>> getChatHistory(int userId) async {
    try {
      final response = await dio.get('/v1/chatbot/$userId');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data
            .map<ChatbotResponse>((json) => ChatbotResponse.fromJson(json))
            .toList();
      }
      return List.empty();
    } catch (err) {
      throw Exception("Failed to load chat message $err");
    }
  }

  @override
  Stream<ChatbotStreamEvent> chatStream(ChatbotRequest request) async* {
    final response = await dio.post<ResponseBody>(
      "/v1/chatbot/stream",
      data: request.toJson(),
      options: Options(
        responseType: ResponseType.stream,
        headers: {"Accept": "text/event-stream", "Cache-Control": "no-cache"},
      ),
    );

    final stream = response.data!.stream.cast<List<int>>().transform(
      utf8.decoder,
    );

    String buffer = '';

    await for (final chunk in stream) {
      buffer += chunk;

      while (buffer.contains('\n\n')) {
        final eventBlock = buffer.substring(0, buffer.indexOf('\n\n'));
        buffer = buffer.substring(buffer.indexOf('\n\n') + 2);

        String? eventName;
        String? dataLine;

        for (final line in eventBlock.split('\n')) {
          if (line.startsWith('event:')) {
            eventName = line.replaceFirst('event:', '').trim();
          } else if (line.startsWith('data:')) {
            dataLine = line.replaceFirst('data:', '').trim();
          }
        }

        if (dataLine != null && dataLine.isNotEmpty) {
          final json = jsonDecode(dataLine);
          yield _mapToEvent(eventName, json);
        }
      }
    }
  }

  ChatbotStreamEvent _mapToEvent(String? event, dynamic json) {
    switch (event) {
      case "status":
        return ChatbotStreamEvent(
          type: ChatbotEventType.status,
          message: json["message"] as String?,
          data: null,
        );

      case "message":
        return ChatbotStreamEvent(
          type: ChatbotEventType.message,
          message: json["message"] as String?,
          data: null,
        );

      case "data":
        final rawData = json["data"];
        ChatbotResponse? parsed;

        parsed = ChatbotResponse.fromJson(rawData);

        return ChatbotStreamEvent(
          type: ChatbotEventType.data,
          message: null,
          data: parsed,
        );

      case "error":
        return ChatbotStreamEvent(
          type: ChatbotEventType.error,
          message: json["message"] as String?,
          data: null,
        );

      case "complete":
        return ChatbotStreamEvent(
          type: ChatbotEventType.complete,
          message: json["message"] as String?,
          data: ChatbotResponse(
            role: ChatRole.AI.name,
            message: json["message"] as String?,
            data: json["data"],
            meta: null,
          ),
        );

      default:
        return ChatbotStreamEvent(
          type: ChatbotEventType.message,
          message: json["message"] as String?,
          data: null,
        );
    }
  }
}
