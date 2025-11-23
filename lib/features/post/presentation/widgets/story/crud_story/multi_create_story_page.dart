import 'dart:io';

import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/presentation/provider/story_list_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/crud_story/media_editor/media_editor_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MultiPreviewPage extends StatefulWidget {
  final List<File> files;
  final int userId;

  const MultiPreviewPage({
    super.key,
    required this.files,
    required this.userId,
  });

  @override
  State<MultiPreviewPage> createState() => _MultiPreviewPageState();
}

class _MultiPreviewPageState extends State<MultiPreviewPage> {
  late PageController _controller;
  int currentIndex = 0;
  bool isPosting = false;
  late StoryCubit _cubit;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    _cubit = context.read<StoryCubit>();
  }

  bool isImage(File file) =>
      file.path.toLowerCase().endsWith(".jpg") ||
      file.path.toLowerCase().endsWith(".png") ||
      file.path.toLowerCase().endsWith(".jpeg") ||
      file.path.toLowerCase().endsWith(".heic");

  Future<void> _editMedia() async {
    final file = widget.files[currentIndex];
    final edited = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaEditorPage(
          file: file,
          isImage: isImage(file),
          isForStory: false,
          isMultiMode: true,
        ),
      ),
    );

    if (edited != null) {
      setState(() => widget.files[currentIndex] = edited);
    }
  }

  Future<void> _postSingle() async {
    if (isPosting) return;

    setState(() => isPosting = true);

    try {
      final file = widget.files[currentIndex];

      await _cubit.createStory(
        file,
        userId: widget.userId,
        type: isImage(file) ? 'image' : 'video',
      );

      // Xóa file vừa đăng khỏi danh sách
      widget.files.removeAt(currentIndex);

      if (widget.files.isEmpty) {
        // Hết story → quay về
        if (mounted) Navigator.pop(context, true);
        return;
      }

      // Nếu còn story → cập nhật index
      if (currentIndex >= widget.files.length) {
        currentIndex = widget.files.length - 1;
      }

      // Chuyển PageView sang story tiếp theo
      _controller.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      await _cubit.loadStories(widget.userId);

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng story thất bại")));
      }
    } finally {
      if (mounted) setState(() => isPosting = false);
    }
  }

  void _postAll() {
    Navigator.pop(context, widget.files);
  }

  @override
  Widget build(BuildContext context) {
    final length = widget.files.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Xem trước (${currentIndex + 1}/$length)",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: isPosting ? null : _editMedia,
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media Viewer
          PageView.builder(
            controller: _controller,
            itemCount: length,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemBuilder: (_, i) {
              final f = widget.files[i];
              return Center(
                child: isImage(f)
                    ? Image.file(f, fit: BoxFit.contain)
                    : const Icon(Icons.videocam, size: 80, color: Colors.white),
              );
            },
          ),

          // Bottom Action Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 12, 10, 0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentIndex == i ? 10 : 7,
                        height: currentIndex == i ? 10 : 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentIndex == i
                              ? Colors.orange
                              : Colors.white54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      // Đăng 1 story
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isPosting ? null : _postSingle,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white60,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: isPosting
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Đăng hình này",
                                  style: TextStyle(color: Colors.black),
                                ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Đăng tất cả (POP như code gốc)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isPosting ? null : _postAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white60,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Đăng tất cả",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
