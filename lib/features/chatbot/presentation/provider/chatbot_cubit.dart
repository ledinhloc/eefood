import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/locations_utils.dart';
import 'package:eefood/core/utils/logger.dart';
import 'package:eefood/features/chatbot/data/models/chatbot_request.dart';
import 'package:eefood/features/chatbot/data/models/chatbot_response.dart';
import 'package:eefood/features/chatbot/data/models/chatbot_stream_event.dart';
import 'package:eefood/features/chatbot/data/models/enum/chat_role.dart';
import 'package:eefood/features/chatbot/domain/repositories/chatbot_repository.dart';
import 'package:eefood/features/chatbot/presentation/provider/chatbot_state.dart';
import 'package:eefood/features/post/data/models/post_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final ChatbotRepository repository = getIt<ChatbotRepository>();

  ChatbotCubit() : super(const ChatbotState());

  void _safeEmit(ChatbotState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  Future<void> deleteChatMessage(int messageId) async {
    //_safeEmit(state.copyWith(isLoading: true, clearError: true));
    try {
      await repository.deleteChatMessage(messageId);

      final index = state.messages.indexWhere((msg) => msg.id == messageId);

      if (index == -1) {
        _safeEmit(
          state.copyWith(
            isLoading: false,
            error: "Không tìm thấy message để xóa",
          ),
        );
        return;
      }

      final updatedMessages = state.messages.sublist(0, index);

      _safeEmit(
        state.copyWith(
          messages: updatedMessages,
          //isLoading: false,
          clearError: true,
        ),
      );
    }
    catch(e) {
      logger.e("Không thể xóa lịch sử chat: $e");
      _safeEmit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể xóa lịch sử chat: $e',
        ),
      );
    }
  }

  Future<void> loadChatHistory(int userId) async {
    _safeEmit(state.copyWith(isLoading: true, clearError: true));
    try {
      final history = await repository.getChatHistory(userId);
      logger.i("Length of chatbot history: ${history.length}");
      _safeEmit(state.copyWith(messages: history, isLoading: false));
    } catch (e) {
      logger.e("Không thể tải lịch sử chat: $e");
      _safeEmit(
        state.copyWith(
          isLoading: false,
          error: 'Không thể tải lịch sử chat: $e',
        ),
      );
    }
  }

  Future<void> loadRecentPosts() async {
    _safeEmit(state.copyWith(isLoadingRecentPosts: true));
    try {
      final posts = await repository.getRecentPostsFromHistory();
      _safeEmit(
        state.copyWith(recentPosts: posts, isLoadingRecentPosts: false),
      );
    } catch (e) {
      _safeEmit(
        state.copyWith(
          isLoadingRecentPosts: false,
          error: 'Không thể tải bài viết gần đây: $e',
        ),
      );
    }
  }

  void togglePostSelection(PostModel post) {
    final selectedPosts = List<PostModel>.from(state.selectedPosts);
    final index = selectedPosts.indexWhere((p) => p.id == post.id);

    if (index >= 0) {
      selectedPosts.removeAt(index);
    } else {
      selectedPosts.add(post);
    }

    _safeEmit(
      state.copyWith(
        selectedPosts: selectedPosts,
        hasSelectedPosts: selectedPosts.isNotEmpty,
      ),
    );
  }

  void clearSelectedPosts() {
    _safeEmit(state.copyWith(selectedPosts: [], hasSelectedPosts: false));
  }

  Future<void> sendMessage(
    String message,
    int userId, {
    String? imageUrl,
  }) async {
    if (message.trim().isEmpty) return;

    final snapshotRecentPosts = state.recentPosts;
    final snapshotIsLoadingRecentPosts = state.isLoadingRecentPosts;
    final snapshotSelectedPosts = List<PostModel>.from(state.selectedPosts);

    final userMsg = ChatbotResponse(
      role: ChatRole.USER.name,
      message: message,
      data: null,
      meta: (imageUrl != null && imageUrl.isNotEmpty)
          ? {'imageUrl': imageUrl}
          : null,
    );
    final committedMessages = [...state.messages, userMsg];

    // Dùng copyWith để _version tự tăng
    _safeEmit(
      state.copyWith(
        messages: committedMessages,
        isSending: true,
        clearError: true,
        streaming: const StreamingMessage(
          phase: StreamingPhase.status,
          statusText: 'Đang xử lý yêu cầu',
        ),
        selectedPosts: snapshotSelectedPosts,
        hasSelectedPosts: snapshotSelectedPosts.isNotEmpty,
        recentPosts: snapshotRecentPosts,
        isLoadingRecentPosts: snapshotIsLoadingRecentPosts,
      ),
    );

    // emit streaming state dựa trên state hiện tại
    void emitWhileStreaming(StreamingMessage s) {
      if (isClosed) return;
      // copyWith luôn tăng _version → Bloc sẽ rebuild
      emit(
        state.copyWith(
          messages: committedMessages,
          isSending: true,
          streaming: s,
          recentPosts: snapshotRecentPosts,
          isLoadingRecentPosts: snapshotIsLoadingRecentPosts,
          selectedPosts: snapshotSelectedPosts,
          hasSelectedPosts: snapshotSelectedPosts.isNotEmpty,
        ),
      );
    }

    void emitDone({
      required List<ChatbotResponse> finalMessages,
      String? error,
    }) {
      if (isClosed) return;
      emit(
        state.copyWith(
          messages: finalMessages,
          isSending: false,
          clearStreaming: true,
          recentPosts: snapshotRecentPosts,
          isLoadingRecentPosts: snapshotIsLoadingRecentPosts,
          selectedPosts: const [],
          hasSelectedPosts: false,
          animatingMessageIndex: error == null
              ? finalMessages.length - 1
              : null,
          clearAnimating: error != null,
          error: error,
        ),
      );
    }

    try {
      final request = ChatbotRequest(
        message: message,
        chatRole: ChatRole.USER.name,
        userId: userId,
        imageUrl: imageUrl,
        location: await LocationUtils.getCurrentLocationInfo(),
        postId: snapshotSelectedPosts.map((p) => p.id).toList(),
        recipeId: snapshotSelectedPosts.map((p) => p.recipeId).toList(),
        time: DateTime.now().toIso8601String(),
      );

      var streaming = const StreamingMessage(
        phase: StreamingPhase.status,
        statusText: "Đang phân tích yêu cầu",
      );

      await for (final event in repository.chatStream(request)) {
        logger.i(
          "Event ${event.type}, message: ${event.message}, data: ${event.data}",
        );
        switch (event.type) {
          case ChatbotEventType.status:
            streaming = streaming.copyWith(
              phase: StreamingPhase.status,
              statusText: event.message ?? 'Đang xử lý...',
            );
            emitWhileStreaming(streaming);
            break;

          case ChatbotEventType.message:
            final incoming = event.message ?? '';

            String newText;

            if (incoming.isEmpty) {
              newText = streaming.messageText;
            } else if (incoming.length >= streaming.messageText.length &&
                incoming.contains(streaming.messageText)) {
              newText = incoming;
            } else {
              newText = streaming.messageText + incoming;
            }

            streaming = streaming.copyWith(
              phase: StreamingPhase.typing,
              messageText: newText,
            );

            emitWhileStreaming(streaming);
            break;

          case ChatbotEventType.data:
            if (event.data != null) {
              streaming = streaming.copyWith(
                data: event.data!.data,
                meta: event.data!.meta,
              );
              emitWhileStreaming(streaming);
            }
            break;

          case ChatbotEventType.complete:
            final finalMsg = ChatbotResponse(
              role: ChatRole.AI.name,
              message: streaming.messageText.isNotEmpty
                  ? streaming.messageText
                  : null,
              data: streaming.data,
              meta: streaming.meta,
            );

            emitDone(finalMessages: [...committedMessages, finalMsg]);
            break;

          case ChatbotEventType.error:
            final errorMsg = ChatbotResponse(
              role: ChatRole.AI.name,
              message: event.message ?? 'Đã xảy ra lỗi, vui lòng thử lại.',
              data: null,
              meta: const {'tool': 'ERROR'},
            );
            emitDone(
              finalMessages: [...committedMessages, errorMsg],
              error: event.message ?? 'Đã xảy ra lỗi',
            );
            break;
        }
      }
    } catch (err) {
      logger.e("Send message error: $err");
      final errorMsg = ChatbotResponse(
        role: ChatRole.AI.name,
        message: 'Không thể gửi tin nhắn, vui lòng thử lại.',
        data: null,
        meta: const {'tool': 'ERROR'},
      );
      emitDone(
        finalMessages: [...committedMessages, errorMsg],
        error: 'Không thể gửi tin nhắn: $err',
      );
    }
  }
}
