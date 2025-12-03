import 'dart:convert';

import 'package:eefood/core/constants/app_keys.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/data/models/story_comment_model.dart';
import 'package:eefood/features/post/presentation/provider/story_comment_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../../auth/data/models/user_model.dart';

class StoryCommentInput extends StatefulWidget {
  final int? storyId;
  final StoryCommentModel? replyingTo;
  final StoryCommentModel? editingComment;
  final VoidCallback? onCancelAction;
  final Function(StoryCommentModel?)? onActionCompleted;
  final FocusNode? focusNode;

  const StoryCommentInput({
    super.key,
    required this.storyId,
    this.replyingTo,
    this.editingComment,
    this.onCancelAction,
    this.onActionCompleted,
    this.focusNode,
  });

  @override
  State<StoryCommentInput> createState() => _StoryCommentInputState();
}

class _StoryCommentInputState extends State<StoryCommentInput> {
  final TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;
  late StoryCommentCubit _commentCubit;
  late bool _isExternalFocusNode;

  bool _isSending = false;
  bool _hasText = false;
  UserModel? user;

  @override
  void initState() {
    super.initState();
    _commentCubit = context.read<StoryCommentCubit>();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
      _isExternalFocusNode = true;
    } else {
      _focusNode = FocusNode();
      _isExternalFocusNode = false;
    }
    _getUser();
    _controller.addListener(_onTextChanged);

    if (widget.editingComment != null) {
      _controller.text = widget.editingComment!.message;
      _hasText = true;
    }
  }

  @override
  void didUpdateWidget(StoryCommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.editingComment != oldWidget.editingComment) {
      if (widget.editingComment != null) {
        _controller.text = widget.editingComment!.message;
        _hasText = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusNode.requestFocus();
        });
      } else if (oldWidget.editingComment != null) {
        _controller.clear();
        _hasText = false;
      }
    }

    if (widget.replyingTo != oldWidget.replyingTo) {
      if (widget.replyingTo != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _focusNode.requestFocus();
        });
      }
    }
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    if (!_isExternalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _sendComment() async {
    if (_controller.text.trim().isEmpty || widget.storyId == null) return;

    setState(() => _isSending = true);

    try {
      if (widget.editingComment != null) {
        // Update comment
        await _commentCubit.updateComment(
          commentId: widget.editingComment!.id!,
          message: _controller.text.trim(),
        );
        showCustomSnackBar(context, 'Đã cập nhật bình luận');
      } else {
        // Add new comment or reply
        await _commentCubit.addComment(
          storyId: widget.storyId!,
          message: _controller.text.trim(),
          parentId: widget.replyingTo?.id,
        );

        if (widget.replyingTo != null) {
          // If replying, reload replies to update count
          await _commentCubit.reloadReplies(widget.replyingTo!.id!);
        }
      }

      _controller.clear();
      _focusNode.unfocus();
      widget.onActionCompleted?.call(null);
    } catch (e) {
      showCustomSnackBar(context, 'Có lỗi xảy ra');
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<UserModel?> _getCurrentUser() async {
    try {
      final prefs = getIt<SharedPreferences>();
      final str = prefs.getString(AppKeys.user);
      return str != null ? UserModel.fromJson(jsonDecode(str)) : null;
    } catch (_) {
      return null;
    }
  }

  void _getUser() async {
    user = await _getCurrentUser();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Action Indicator (Reply/Edit)
        if (widget.replyingTo != null || widget.editingComment != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(
                  widget.editingComment != null ? Icons.edit : Icons.reply,
                  size: 16,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.editingComment != null
                        ? 'Đang chỉnh sửa bình luận'
                        : 'Đang trả lời ${widget.replyingTo?.username ?? ""}',
                    style: const TextStyle(fontSize: 13, color: Colors.blue),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: widget.onCancelAction,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

        // Input Section
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: user?.avatarUrl != null
                      ? NetworkImage(user!.avatarUrl!)
                      : null,
                  child: user?.avatarUrl == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 12),

                // Input Field
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 100),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: widget.editingComment != null
                            ? 'Cập nhật bình luận...'
                            : widget.replyingTo != null
                            ? 'Trả lời...'
                            : 'Viết bình luận...',
                        border: InputBorder.none,
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendComment(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Send Button
                _isSending
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : GestureDetector(
                        onTap: _hasText ? _sendComment : null,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            widget.editingComment != null
                                ? Icons.check
                                : Icons.send_rounded,
                            color: _hasText ? Colors.blue : Colors.grey,
                            size: 24,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
