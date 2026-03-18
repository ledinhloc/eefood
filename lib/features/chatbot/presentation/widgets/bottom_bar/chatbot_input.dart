import 'dart:io';

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/core/utils/file_upload.dart';
import 'package:eefood/core/utils/media_picker.dart';
import 'package:eefood/core/utils/speech_helper.dart';
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

    //await cubit.loadChatHistory(widget.userId!);
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
    final theme = Theme.of(context);
    final cubit = context.read<ChatbotCubit>();
    await showCustomBottomSheet(context, [
      BottomSheetOption(
        icon: Icon(Icons.image_rounded, color: theme.colorScheme.primary),
        title: 'Chọn hình từ thư viện',
        onTap: _pickImage,
      ),
      BottomSheetOption(
        icon: Icon(
          Icons.collections_bookmark_rounded,
          color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242424) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Center(
                  child: SpinKitCircle(color: theme.colorScheme.primary),
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

  Future<void> _handleVoiceSearch() async {
    final helper = SpeechHelper();
    final message = await helper.listenOnceWithUI(context);
    if (message != null && context.mounted) {
      setState(() => _textController.text = message);
    }
    _handleSendMessage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ── Màu semantic ────────────────────────────────────────────────────────
    // Nền ô input: xám nhạt (light) / xám than (dark)
    final Color inputBg = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFF3F4F6);

    // Màu hint & icon mic
    final Color hintAndMicColor = isDark
        ? const Color(0xFF6B6B6B)
        : Colors.grey;

    // Nút "+" khi active: nền đen (light) / trắng ngà (dark)
    final Color addBtnBg = isDark ? const Color(0xFFEFEFEF) : Colors.black;
    final Color addBtnIcon = isDark ? Colors.black : Colors.white;

    // Nút "+" khi disabled (đã có post)
    final Color addBtnDisabledBg = isDark
        ? const Color(0xFF3A3A3A)
        : Colors.grey.shade200;
    final Color addBtnDisabledIcon = isDark
        ? const Color(0xFF555555)
        : Colors.grey.shade400;

    // Nút send khi không có text: nền đen (light) / trắng ngà (dark)
    final Color idleSendBg = isDark ? const Color(0xFFEFEFEF) : Colors.black;
    final Color idleSendIcon = isDark ? Colors.black : Colors.white;

    return SafeArea(
      top: false,
      child: Container(
        color: Colors.transparent,
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

            // ── Input row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Nút "+"
                  BlocSelector<ChatbotCubit, ChatbotState, bool>(
                    selector: (state) => state.hasSelectedPosts,
                    builder: (context, hasSelectedPosts) => _circleButton(
                      icon: Icons.add_rounded,
                      background: hasSelectedPosts
                          ? addBtnDisabledBg
                          : addBtnBg,
                      iconColor: hasSelectedPosts
                          ? addBtnDisabledIcon
                          : addBtnIcon,
                      onTap: hasSelectedPosts ? null : _showOptionsBottomSheet,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Ô nhập text
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(14, 0, 6, 0),
                      decoration: BoxDecoration(
                        color: inputBg,
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
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                              onSubmitted: (_) {
                                final hasSelected = context
                                    .read<ChatbotCubit>()
                                    .state
                                    .hasSelectedPosts;
                                if (_hasText || hasSelected) {
                                  _handleSendMessage();
                                }
                              },
                              decoration: InputDecoration(
                                filled: false,
                                hintText: 'Hỏi đáp với eeFoodBot',
                                hintStyle: TextStyle(color: hintAndMicColor),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                            ),
                          ),

                          // Icon mic (khi chưa có text)
                          if (!_hasText)
                            GestureDetector(
                              onTap: _handleVoiceSearch,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: Icon(
                                  Icons.mic_none_rounded,
                                  color: hintAndMicColor,
                                ),
                              ),
                            ),

                          const SizedBox(width: 2),

                          // Nút send / graphic_eq
                          BlocSelector<ChatbotCubit, ChatbotState, bool>(
                            selector: (state) => state.hasSelectedPosts,
                            builder: (context, hasSelectedPosts) {
                              final canSend = _hasText || hasSelectedPosts;
                              return _circleButton(
                                icon: canSend
                                    ? Icons.arrow_upward_rounded
                                    : Icons.graphic_eq_rounded,
                                // Khi có thể gửi → cam chủ đạo
                                // Khi idle      → đen/trắng theo theme
                                background: canSend
                                    ? theme.colorScheme.primary
                                    : idleSendBg,
                                iconColor: canSend
                                    ? Colors.white
                                    : idleSendIcon,
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
