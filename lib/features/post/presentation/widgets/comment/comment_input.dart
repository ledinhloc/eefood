import 'dart:io';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/features/post/data/models/comment_model.dart';
import 'package:eefood/features/post/presentation/provider/comment_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_media_review.dart';
import 'package:eefood/features/post/presentation/widgets/comment/comment_reply_box.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentInput extends StatefulWidget {
  final bool isSubmitting;
  final CommentModel? replyingTo;
  final VoidCallback onCancelReply;
  final Function(String, List<String>, List<String>) onSubmit;

  const CommentInput({
    super.key,
    required this.isSubmitting,
    this.replyingTo,
    required this.onCancelReply,
    required this.onSubmit,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final List<File> _selectedImages = [];
  final List<File> _selectedVideos = [];

  bool _showEmojiPicker = false;
  bool get _hasText => _controller.text.trim().isNotEmpty;
  String _replyPrefix = '';

  CommentListCubit get _cubit => context.read<CommentListCubit>();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) _hideEmojiPicker();
    });

    if (widget.replyingTo != null) {
      _applyReplyPrefix(widget.replyingTo!);
    }
  }

  @override
  void didUpdateWidget(CommentInput oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.replyingTo?.id != widget.replyingTo?.id) {
      if (widget.replyingTo != null) {
        _applyReplyPrefix(widget.replyingTo!);
      } else {
        _resetInput();
      }
    }
  }

  void _applyReplyPrefix(CommentModel replyingTo) {
    _replyPrefix = '@${replyingTo.username} ';
    _controller.text = _replyPrefix;
    _focusTextFieldToEnd();
  }

  void _focusTextFieldToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
  }

  void _resetInput() {
    _controller.clear();
    _replyPrefix = '';
    _selectedImages.clear();
    _selectedVideos.clear();
    _hideEmojiPicker();
    _focusNode.unfocus();
    setState(() {});
  }

  void _hideEmojiPicker() => setState(() => _showEmojiPicker = false);
  void _toggleEmojiPicker() {
    if (_showEmojiPicker) {
      _focusNode.requestFocus();
    } else {
      _focusNode.unfocus();
    }
    setState(() => _showEmojiPicker = !_showEmojiPicker);
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 2) return;
    final file = await MediaPicker.pickImage();
    if (file != null) setState(() => _selectedImages.add(file));
  }

  Future<void> _pickVideo() async {
    if (_selectedVideos.length >= 2) return;
    final file = await MediaPicker.pickVideo();
    if (file != null) setState(() => _selectedVideos.add(file));
  }

  void _removeImage(int index) => setState(() => _selectedImages.removeAt(index));
  void _removeVideo(int index) => setState(() => _selectedVideos.removeAt(index));

  Future<void> _submitComment() async {
    if (widget.isSubmitting || !_hasText) return;

    final content = _controller.text.trim();
    if (_replyPrefix.isNotEmpty && content == _replyPrefix.trim()) return;

    try {
      final imageUrls = await _cubit.uploadMediaFiles(_selectedImages);
      final videoUrls = await _cubit.uploadMediaFiles(_selectedVideos);

      widget.onSubmit(content, imageUrls, videoUrls);

      _resetInput();
      widget.onCancelReply();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    }
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon),
      visualDensity: VisualDensity.compact,
      onPressed: onTap,
    );
  }

  Widget _buildTextField() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.replyingTo != null
                ? 'Viết phản hồi...'
                : 'Viết bình luận...',
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            isDense: true,
          ),
          maxLines: 1,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: widget.isSubmitting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.send,
              color: _hasText ? Colors.blue : Colors.grey.shade500),
      onPressed: _hasText ? _submitComment : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (_focusNode.hasFocus) _focusNode.unfocus();
        _hideEmojiPicker();
      },
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(bottom: _showEmojiPicker ? 0 : bottomInset),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.replyingTo != null)
                CommentReplyTag(
                  replyingTo: widget.replyingTo!,
                  onCancel: () {
                    widget.onCancelReply();
                    _resetInput();
                  },
                ),
              CommentMediaPreview(
                images: _selectedImages,
                videos: _selectedVideos,
                onRemoveImage: _removeImage,
                onRemoveVideo: _removeVideo,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                  ),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    _buildActionButton(Icons.emoji_emotions_outlined, _toggleEmojiPicker),
                    _buildActionButton(Icons.photo_library_outlined, _pickImage),
                    _buildActionButton(Icons.videocam_outlined, _pickVideo),
                    _buildTextField(),
                    _buildSendButton(),
                  ],
                ),
              ),
              Offstage(
                offstage: !_showEmojiPicker,
                child: SizedBox(
                  height: 256,
                  child: EmojiPicker(
                    textEditingController: _controller,
                    config: const Config(
                      emojiViewConfig: EmojiViewConfig(emojiSizeMax: 20),
                      bottomActionBarConfig: BottomActionBarConfig(enabled: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
