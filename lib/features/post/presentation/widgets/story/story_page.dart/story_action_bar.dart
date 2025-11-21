import 'package:eefood/core/utils/reaction_helper.dart';
import 'package:eefood/features/post/data/models/reaction_type.dart';
import 'package:eefood/features/post/presentation/provider/story_reaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoryActionBar extends StatefulWidget {
  final Function(String) onSendComment;
  final Function(ReactionType) onReact;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final Function(Offset position)? onOpenReactionPopup;
  final int? storyId; // Thêm storyId để track reaction cho từng story

  const StoryActionBar({
    super.key,
    required this.onSendComment,
    required this.onReact,
    required this.onPause,
    required this.onResume,
    this.onOpenReactionPopup,
    this.storyId,
  });

  @override
  State<StoryActionBar> createState() => _StoryActionBarState();
}

class _StoryActionBarState extends State<StoryActionBar> {
  final GlobalKey _reactKey = GlobalKey();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus)
        widget.onPause();
      else
        widget.onResume();
    });
  }

  void _showPopup() {
    widget.onPause();
    final renderBox =
        _reactKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero);
    widget.onOpenReactionPopup?.call(position);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryReactionCubit, StoryReactionState>(
      builder: (context, reactionState) {
        // Lấy reaction hiện tại từ state, fallback về LOVE
        final currentReaction =
            reactionState.reaction?.reactionType ?? ReactionType.LOVE;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.55)),
          child: Row(
            children: [
              /// Reaction button
              GestureDetector(
                key: _reactKey,
                onTap: () {
                  widget.onPause();
                  widget.onReact(currentReaction);
                  widget.onResume();
                },
                onLongPressStart: (_) {
                  _showPopup(); // long press → mở popup chọn reaction
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: reactionState.isLoading
                      ? const SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          ReactionHelper.emoji(currentReaction),
                          style: const TextStyle(fontSize: 26),
                        ),
                ),
              ),

              const SizedBox(width: 12),

              /// Comment input
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "Viết bình luận...",
                      hintStyle: TextStyle(color: Colors.white70),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              /// Send button
              _isSending
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : GestureDetector(
                      onTap: _submit,
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      ),
                    ),
            ],
          ),
        );
      },
    );
  }

  void _submit() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    await widget.onSendComment(_controller.text.trim());
    _controller.clear();
    _focusNode.unfocus();
    setState(() => _isSending = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
