import 'dart:async';

import 'package:eefood/core/constants/app_constants.dart';
import 'package:eefood/features/chatbot/presentation/screens/chatbot_bubble.dart';
import 'package:flutter/material.dart';

class ChatbotFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final List<String>? messages;

  const ChatbotFAB({super.key, required this.onPressed, this.messages});

  @override
  State<ChatbotFAB> createState() => _ChatbotFABState();
}

class _ChatbotFABState extends State<ChatbotFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  Timer? _timer;
  String? _currentMessage;
  int _msgIndex = 0;
  bool _showBubble = false;

  List<String> get _messages =>
      widget.messages ?? AppConstants.chatBubbleMessages;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(seconds: 2), _showNext);
  }

  void _showNext() {
    if (!mounted) return;
    setState(() {
      _currentMessage = _messages[_msgIndex % _messages.length];
      _showBubble = true;
      _msgIndex++;
    });
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 3500), () {
      if (!mounted) return;
      setState(() => _showBubble = false);
      _timer = Timer(const Duration(seconds: 4), _showNext);
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 130,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // ── Chat bubble (hiện phía trên robot) ──
          if (_showBubble && _currentMessage != null)
            Positioned(
              bottom: 78,
              right: 0,
              child: ChatBubbleWidget(
                key: ValueKey(_currentMessage),
                message: _currentMessage!,
              ),
            ),

          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, __) => Positioned(
              bottom: 2,
              child: Container(
                width: 54 * _glowAnim.value,
                height: 16 * _glowAnim.value,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.45),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: widget.onPressed,
              child: ClipOval(
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Image.network(
                    'https://media.istockphoto.com/id/2158683000/vector/chat-bot-vector-icon.jpg?s=612x612&w=0&k=20&c=ACzE9Oi5WsYRd3PwaJD2Kcf3DbLpIKiWqSS3vS4806A=',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.smart_toy_rounded,
                      color: Color(0xFF2196F3),
                      size: 52,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
