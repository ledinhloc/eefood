import 'package:eefood/features/chatbot/data/models/chatbot_request.dart';
import 'package:eefood/features/chatbot/data/models/chatbot_response.dart';
import 'package:eefood/features/chatbot/data/models/chatbot_stream_event.dart';
import 'package:eefood/features/post/data/models/post_model.dart';

abstract class ChatbotRepository {
  Future<void> deleteChatMessage(int id);
  Stream<ChatbotStreamEvent> chatStream(ChatbotRequest request);
  Future<List<PostModel>> getRecentPostsFromHistory();
  Future<List<ChatbotResponse>> getChatHistory(int userId);
}
