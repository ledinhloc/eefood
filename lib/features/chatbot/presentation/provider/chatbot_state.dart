import 'package:eefood/features/chatbot/data/models/chatbot_response.dart';
import 'package:eefood/features/post/data/models/post_model.dart';

enum StreamingPhase {
  idle, 
  status, 
  typing, 
  done, 
}

class StreamingMessage {
  final StreamingPhase phase;
  final String statusText; 
  final String messageText; 
  final List<dynamic>? data;
  final Map<String, dynamic>? meta;

  const StreamingMessage({
    this.phase = StreamingPhase.idle,
    this.statusText = '',
    this.messageText = '',
    this.data,
    this.meta,
  });

  StreamingMessage copyWith({
    StreamingPhase? phase,
    String? statusText,
    String? messageText,
    List<dynamic>? data,
    Map<String, dynamic>? meta,
  }) {
    return StreamingMessage(
      phase: phase ?? this.phase,
      statusText: statusText ?? this.statusText,
      messageText: messageText ?? this.messageText,
      data: data ?? this.data,
      meta: meta ?? this.meta,
    );
  }
}

class ChatbotState {
  
  final List<ChatbotResponse> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;
  final List<PostModel> recentPosts;
  final bool isLoadingRecentPosts;
  final List<PostModel> selectedPosts;
  final bool hasSelectedPosts;
  final StreamingMessage? streaming;
  final int? animatingMessageIndex;

  final int _version;

  const ChatbotState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
    this.recentPosts = const [],
    this.isLoadingRecentPosts = false,
    this.selectedPosts = const [],
    this.hasSelectedPosts = false,
    this.streaming,
    this.animatingMessageIndex,
    int version = 0,
  }) : _version = version;

  ChatbotState copyWith({
    List<ChatbotResponse>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
    List<PostModel>? recentPosts,
    bool? isLoadingRecentPosts,
    List<PostModel>? selectedPosts,
    bool? hasSelectedPosts,
    StreamingMessage? streaming,
    bool clearStreaming = false,
    int? animatingMessageIndex,
    bool clearAnimating = false,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      recentPosts: recentPosts ?? this.recentPosts,
      isLoadingRecentPosts: isLoadingRecentPosts ?? this.isLoadingRecentPosts,
      selectedPosts: selectedPosts ?? this.selectedPosts,
      hasSelectedPosts: hasSelectedPosts ?? this.hasSelectedPosts,
      streaming: clearStreaming ? null : (streaming ?? this.streaming),
      animatingMessageIndex: clearAnimating
          ? null
          : (animatingMessageIndex ?? this.animatingMessageIndex),
      version: _version + 1,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatbotState) return false;
    return _version == other._version;
  }

  @override
  int get hashCode => _version.hashCode;
}
