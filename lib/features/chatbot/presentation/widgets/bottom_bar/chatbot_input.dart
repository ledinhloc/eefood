import 'dart:io';

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/features/chatbot/presentation/provider/chatbot_cubit.dart';
import 'package:eefood/features/chatbot/presentation/provider/chatbot_state.dart';
import 'package:eefood/features/chatbot/presentation/widgets/bottom_bar/image_preview_tag.dart';
import 'package:eefood/features/chatbot/presentation/widgets/bottom_bar/recent_post_bottom_sheet.dart';
import 'package:eefood/features/chatbot/presentation/widgets/bottom_bar/selected_post_detail_sheet.dart';
import 'package:eefood/features/chatbot/presentation/widgets/bottom_bar/selected_post_tag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatbotInput extends StatefulWidget {
  final int? userId;
  const ChatbotInput({super.key, this.userId});

  @override
  State<ChatbotInput> createState() => _ChatbotInputState();
}

class _ChatbotInputState extends State<ChatbotInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final _fileUpload = getIt<FileUploader>();

  bool _hasText = false;
  File? _imageFile;
  String? _imageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    final message = _textController.text.trim();
    final cubit = context.read<ChatbotCubit>();
    final hasSelectedPosts = cubit.state.hasSelectedPosts;
    final hasImage = _imageUrl != null;

    if (message.isNotEmpty || hasSelectedPosts || hasImage) {
      if (widget.userId != null) {
        cubit.sendMessage(message, widget.userId!, imageUrl: _imageUrl);
      }
      _textController.clear();
      _focusNode.unfocus();
      cubit.clearSelectedPosts();
      setState(() {
        _imageFile = null;
        _imageUrl = null;
      });
    }
  }

  Future<void> _pickImage() async {
    final File? image = await MediaPicker.pickImageNew();
    if (image != null) {
      setState(() => _isUploadingImage = true);
      try {
        final url = await _fileUpload.uploadFile(image);
        if (url.isNotEmpty) {
          setState(() {
            _imageFile = image;
            _imageUrl = url;
          });
        }
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  void _clearImage() {
    setState(() {
      _imageFile = null;
      _imageUrl = null;
    });
  }

  Future<void> _showOptionsBottomSheet() async {
    final cubit = context.read<ChatbotCubit>();
    await showCustomBottomSheet(context, [
      BottomSheetOption(
        icon: const Icon(Icons.image_rounded, color: Colors.blue),
        title: 'Chọn hình từ thư viện',
        onTap: _pickImage,
      ),
      BottomSheetOption(
        icon: const Icon(
          Icons.collections_bookmark_rounded,
          color: Colors.deepOrange,
        ),
        title: 'Bài viết gần đây',
        onTap: () async {
          Future.microtask(() {
            if (mounted) {
              _showRecentPostsSheet(cubit);
            }
          });
        },
      ),
    ]);
  }

  void _showRecentPostsSheet(ChatbotCubit cubit) {
    if (!mounted) return;

    if (cubit.state.recentPosts.isEmpty && !cubit.state.isLoadingRecentPosts) {
      cubit.loadRecentPosts();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<ChatbotCubit, ChatbotState>(
          buildWhen: (prev, curr) =>
              prev.isLoadingRecentPosts != curr.isLoadingRecentPosts ||
              prev.recentPosts != curr.recentPosts ||
              prev.selectedPosts != curr.selectedPosts,
          builder: (builderContext, state) {
            if (state.isLoadingRecentPosts) {
              return Container(
                height: 300,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: const Center(
                  child: SpinKitCircle(color: Colors.deepOrange),
                ),
              );
            }

            return RecentPostBottomSheet(
              posts: state.recentPosts,
              selectedPosts: state.selectedPosts,
              onTogglePost: (post) {
                cubit.togglePostSelection(post);
              },
              onConfirm: () {
                Navigator.of(sheetContext).pop();
              },
            );
          },
        ),
      ),
    );
  }

  void _showSelectedPostsDetail() {
    final cubit = context.read<ChatbotCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<ChatbotCubit, ChatbotState>(
          buildWhen: (prev, curr) => prev.selectedPosts != curr.selectedPosts,
          builder: (builderContext, state) {
            return SelectedPostDetailSheet(
              selectedPosts: state.selectedPosts,
              onRemovePost: (post) {
                cubit.togglePostSelection(post);
              },
            );
          },
        ),
      ),
    );
  }

  void _handlePickImage() {
    print('Pick image');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<ChatbotCubit, ChatbotState>(
              buildWhen: (prev, curr) =>
                  prev.hasSelectedPosts != curr.hasSelectedPosts ||
                  prev.selectedPosts != curr.selectedPosts,
              builder: (context, state) {
                if (!state.hasSelectedPosts) return const SizedBox.shrink();
                return SelectedPostTag(
                  selectedPosts: state.selectedPosts,
                  onTap: _showSelectedPostsDetail,
                  onClear: () =>
                      context.read<ChatbotCubit>().clearSelectedPosts(),
                );
              },
            ),

            if (_imageFile != null || _isUploadingImage)
              ImagePreviewTag(
                imageFile: _imageFile,
                isUploading: _isUploadingImage,
                onClear: _clearImage,
              ),

            // Input row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  BlocSelector<ChatbotCubit, ChatbotState, bool>(
                    selector: (state) => state.hasSelectedPosts,
                    builder: (context, hasSelectedPosts) => _circleButton(
                      icon: Icons.add_rounded,
                      background: hasSelectedPosts
                          ? Colors.grey.shade200
                          : Colors.black,
                      iconColor: hasSelectedPosts
                          ? Colors.grey.shade400
                          : Colors.white,
                      onTap: hasSelectedPosts ? null : _showOptionsBottomSheet,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Text input + send
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) {
                                final hasSelected = context
                                    .read<ChatbotCubit>()
                                    .state
                                    .hasSelectedPosts;
                                if (_hasText || hasSelected) {
                                  _handleSendMessage();
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "Hỏi đáp với eeFoodBot",
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),
                          if (!_hasText)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.mic_none_rounded,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(width: 2),
                          BlocSelector<ChatbotCubit, ChatbotState, bool>(
                            selector: (state) => state.hasSelectedPosts,
                            builder: (context, hasSelectedPosts) {
                              final canSend = _hasText || hasSelectedPosts;
                              return _circleButton(
                                icon: canSend
                                    ? Icons.arrow_upward_rounded
                                    : Icons.graphic_eq_rounded,
                                background: canSend
                                    ? Colors.deepOrangeAccent
                                    : Colors.black,
                                iconColor: Colors.white,
                                onTap: canSend ? _handleSendMessage : null,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    VoidCallback? onTap,
    Color background = const Color(0xFFF3F4F6),
    Color iconColor = Colors.black,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: iconColor),
      ),
    );
  }
}
