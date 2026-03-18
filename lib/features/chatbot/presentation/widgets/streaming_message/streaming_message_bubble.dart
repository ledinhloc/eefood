import 'package:eefood/features/chatbot/presentation/provider/chatbot_state.dart';
import 'package:eefood/features/chatbot/presentation/widgets/streaming_message/dots_loading.dart';
import 'package:eefood/features/chatbot/presentation/widgets/streaming_message/streaming_data_card.dart';
import 'package:eefood/features/chatbot/presentation/widgets/typing_text.dart';
import 'package:flutter/material.dart';

class StreamingMessageBubble extends StatelessWidget {
  final StreamingMessage streaming;

  const StreamingMessageBubble({super.key, required this.streaming});

  @override
  Widget build(BuildContext context) {
    final hasText = streaming.messageText.isNotEmpty;
    final hasData = streaming.data != null && streaming.data!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasText) _TextBubble(text: streaming.messageText),
                if (!hasText && streaming.statusText.isNotEmpty)
                  _StatusBubble(text: streaming.statusText),
                if (hasData) ...[
                  const SizedBox(height: 8),
                  StreamingDataCard(
                    metaType: streaming.meta?['tool'] as String?,
                    data: streaming.data!,
                    animate: false,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFF8C61)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.restaurant, color: Colors.white, size: 16),
    );
  }
}

class _StatusBubble extends StatelessWidget {
  final String text;
  const _StatusBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status text với animated switcher (smooth khi đổi text)
          Flexible(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Text(
                text,
                key: ValueKey(text),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
            ),
          ),
          // Dots animation
          const SizedBox(width: 10),
          const DotsLoadingIndicator(color: Color(0xFFFF6B35), dotSize: 6),
        ],
      ),
    );
  }
}

class _TextBubble extends StatelessWidget {
  final String text;
  const _TextBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TypingText(
        text: text,
        animate: true,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 15,
          height: 1.5,
        ),
      ),
    );
  }
}
