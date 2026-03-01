import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/chatbot/presentation/provider/chatbot_cubit.dart';
import 'package:eefood/features/chatbot/presentation/widgets/streaming_message/streaming_data_card.dart';
import 'package:eefood/features/chatbot/presentation/widgets/typing_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatbotMessage extends StatelessWidget {
  final int? messageId;
  final String? message;
  final String role;
  final List<dynamic>? data;
  final Map<String, dynamic>? meta;
  final bool animate;

  const ChatbotMessage({
    super.key,
    this.messageId,
    this.message,
    required this.role,
    this.data,
    this.meta,
    this.animate = false,
  });

  bool get _isUser => role == 'USER';
  String? get _metaType => meta?['tool'] as String?;
  bool get _isError => _metaType == 'ERROR';
  String? get _imageUrl => meta?['imageUrl'] as String?;

  Future<void> _showOptionsBottomSheet(BuildContext context) async {
    final cubit = context.read<ChatbotCubit>();
    final options = <BottomSheetOption>[];
    
    if (message != null && message!.isNotEmpty) {
      options.add(
        BottomSheetOption(
          icon: const Icon(Icons.copy_rounded, color: Colors.blue),
          title: 'Sao chép nội dung',
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: message!));
            if (context.mounted) {
              showCustomSnackBar(context, "Đã sao chép vào bộ nhớ tạm");
            }
          },
        ),
      );
    }

    if (messageId != null) {
      options.add(
        BottomSheetOption(
          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
          title: 'Xóa tin nhắn',
          onTap: () {
            cubit.deleteChatMessage(messageId!);
          },
        ),
      );
    }

    if (options.isEmpty) return;

    await showCustomBottomSheet(context, options);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: _isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!_isUser) ...[_buildAvatar(), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: _isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (_isError)
                  _ErrorBubble(message: message ?? 'Đã xảy ra lỗi')
                else ...[
                  if (_isUser &&
                      _imageUrl != null &&
                      _imageUrl!.isNotEmpty) ...[
                    _ImageBubble(imageUrl: _imageUrl!),
                    if (message != null && message!.isNotEmpty)
                      const SizedBox(height: 6),
                  ],
                  if (message != null && message!.isNotEmpty)
                    _MessageBubble(
                      text: message!,
                      isUser: _isUser,
                      animate: animate,
                      onDeleted: () => _showOptionsBottomSheet(context),
                    ),
                  if (data != null && data!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    StreamingDataCard(
                      metaType: _metaType,
                      data: data!,
                      animate: animate,
                    ),
                  ],
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

class _ImageBubble extends StatelessWidget {
  final String imageUrl;

  const _ImageBubble({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(4),
        ),
        child: Stack(
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: 220,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 220,
                  height: 160,
                  color: Colors.grey.shade100,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.deepOrange.shade200,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) => Container(
                width: 220,
                height: 120,
                color: Colors.grey.shade100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      color: Colors.grey.shade400,
                      size: 32,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Không tải được ảnh',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Subtle gradient overlay at bottom for visual depth
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.08),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool animate;
  final VoidCallback onDeleted;

  const _MessageBubble({
    required this.text,
    required this.isUser,
    required this.animate,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onDeleted,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? Colors.deepOrange : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
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
          // Animate chỉ lần đầu khi message được commit
          animate: !isUser && animate,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ErrorBubble extends StatelessWidget {
  final String message;
  const _ErrorBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
