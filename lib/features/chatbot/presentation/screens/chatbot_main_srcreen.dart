import 'package:eefood/features/chatbot/presentation/provider/chatbot_cubit.dart';
import 'package:eefood/features/chatbot/presentation/provider/chatbot_state.dart';
import 'package:eefood/features/chatbot/presentation/widgets/bottom_bar/chatbot_input.dart';
import 'package:eefood/features/chatbot/presentation/widgets/streaming_message/chatbot_message.dart';
import 'package:eefood/features/chatbot/presentation/widgets/streaming_message/streaming_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatbotMainScreen extends StatefulWidget {
  final int userId;
  const ChatbotMainScreen({super.key, required this.userId});

  @override
  State<ChatbotMainScreen> createState() => _ChatbotMainScreenState();
}

class _ChatbotMainScreenState extends State<ChatbotMainScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final chatbotCubit = context.read<ChatbotCubit>();
    chatbotCubit.loadChatHistory(widget.userId);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final maxExtent = _scrollController.position.maxScrollExtent;
      if (animate) {
        _scrollController.animateTo(
          maxExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(maxExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatbotCubit, ChatbotState>(
              listenWhen: (prev, curr) {
                // Scroll khi load history xong lần đầu
                final justFinishedLoading =
                    prev.isLoading &&
                    !curr.isLoading &&
                    curr.messages.isNotEmpty;
                // Scroll khi đang send/stream
                final streamingChanged = prev.streaming != curr.streaming;
                // Scroll khi messages mới được thêm
                final messagesGrew =
                    curr.messages.length > prev.messages.length;
                return justFinishedLoading || streamingChanged || messagesGrew;
              },
              listener: (context, state) {
                final justFinishedLoading =
                    state.messages.isNotEmpty &&
                    !state.isLoading &&
                    !state.isSending;

                _scrollToBottom(
                  animate: state.isSending || state.streaming != null,
                );
              },
              buildWhen: (prev, curr) {
                if (prev.isLoading != curr.isLoading) return true;
                if (prev.messages != curr.messages) return true;  
                if (prev.streaming != curr.streaming) return true;
                if (prev.animatingMessageIndex != curr.animatingMessageIndex) return true;
                return false;
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.messages.isEmpty && state.streaming == null) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  // +1 nếu đang stream (thêm StreamingMessageBubble ở cuối)
                  itemCount:
                      state.messages.length + (state.streaming != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Item cuối: streaming bubble
                    if (state.streaming != null &&
                        index == state.messages.length) {
                      return StreamingMessageBubble(
                        streaming: state.streaming!,
                      );
                    }

                    // Các message đã hoàn chỉnh
                    final message = state.messages[index];
                    final shouldAnimate = index == state.animatingMessageIndex;

                    return ChatbotMessage(
                      key: ValueKey('msg_$index'),
                      message: message.message,
                      role: message.role,
                      data: message.data,
                      meta: message.meta,
                      animate: shouldAnimate,
                    );
                  },
                );
              },
            ),
          ),
          ChatbotInput(userId: widget.userId),
        ],
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
              ),
            ),
            child: const Icon(Icons.restaurant, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'eeFoodBot',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
          ),
        ],
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Colors.grey.shade100),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.deepOrange.shade100, Colors.deepOrange.shade50],
              ),
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              size: 36,
              color: Colors.deepOrange.shade300,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Xin chào! Tôi là eeFoodBot 👋',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hỏi tôi về công thức nấu ăn,\ngợi ý món ăn, hay bất cứ điều gì!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
