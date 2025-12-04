import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/utils/save_file_media.dart';
import 'package:eefood/core/widgets/custom_bottom_sheet.dart';
import 'package:eefood/core/widgets/snack_bar.dart';
import 'package:eefood/features/post/data/models/story_collection_model.dart';
import 'package:eefood/features/post/presentation/provider/story_collection_cubit.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/dialog/confirm_dialog.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/dialog/create_update_collection_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

class StoryCollectionGridCard extends StatefulWidget {
  final StoryCollectionModel collection;
  final VoidCallback onTap;
  final int currentUserId;
  const StoryCollectionGridCard({
    super.key,
    required this.collection,
    required this.onTap,
    required this.currentUserId,
  });

  @override
  State<StoryCollectionGridCard> createState() =>
      _StoryCollectionGridCardState();
}

class _StoryCollectionGridCardState extends State<StoryCollectionGridCard> {
  void _openCollectionOption(BuildContext context) async {
    final cubit = context.read<StoryCollectionCubit>();
    final isOwnner = widget.collection.userId == widget.currentUserId;

    await showCustomBottomSheet(context, [
      if (isOwnner) ...[
        BottomSheetOption(
          icon: const Icon(Icons.edit, color: Colors.greenAccent),
          title: 'Chỉnh sửa danh mục bảng tin',
          onTap: () => _showUpdateCollectionDialog(widget.collection, context),
        ),
        BottomSheetOption(
          icon: const Icon(Icons.delete_outlined, color: Colors.redAccent),
          title: 'Xóa danh mục bảng tin',
          onTap: () => _handleDeleteCollection(widget.collection, cubit),
        ),
      ],
      BottomSheetOption(
        icon: const Icon(
          Icons.download_for_offline_rounded,
          color: Colors.blueAccent,
        ),
        title: 'Tải hình ảnh',
        onTap: () => _downloadImage(widget.collection.imageUrl, context),
      ),
    ]);
  }

  Future<void> _downloadImage(String imageUrl, BuildContext context) async {
    try {
      final uri = Uri.parse(imageUrl);
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(uri);
      final response = await request.close();

      if (response.statusCode != 200) {
        showCustomSnackBar(
          context,
          "Không thể tải ảnh (mã lỗi ${response.statusCode})",
          isError: true,
        );
        return;
      }
      final bytes = await consolidateHttpClientResponseBytes(response);
      final tempDir = await getTemporaryDirectory();
      final file = File(
        "${tempDir.path}/download_${DateTime.now().millisecondsSinceEpoch}.jpg",
      );
      await file.writeAsBytes(bytes);

      //Lưu vào thư viện
      final savedPath = await SaveFileMedia.saveFileToGallery(
        file,
        isImage: true,
      );

      if (savedPath != null) {
        showCustomSnackBar(context, "Đã lưu ảnh vào thư viện!");
      } else {
        showCustomSnackBar(context, "Không thể lưu ảnh", isError: true);
      }
    } catch (e) {
      showCustomSnackBar(context, "Lỗi khi tải ảnh: $e", isError: true);
    }
  }

  Future<void> _handleDeleteCollection(
    StoryCollectionModel collection,
    StoryCollectionCubit cubit,
  ) async {
    if (collection.id == null) return;

    final confirm = await CollectionDialogs.showDeleteDialog(
      context,
      collection.name ?? '',
    );

    if (confirm == true) {
      await cubit.deleteCollection(collection.id!);
    }
  }

  void _showUpdateCollectionDialog(
    StoryCollectionModel collection,
    BuildContext context,
  ) {
    final cubit = context.read<StoryCollectionCubit>();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: CreateAndUpdateCollectionDialog(
          userId: widget.currentUserId,
          collection: collection,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              CachedNetworkImage(
                imageUrl: widget.collection.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.collections_bookmark,
                    size: 48,
                    color: Colors.grey,
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),

              // Collection Info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.collection.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.collection.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.collection.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Icon overlay top right
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    _openCollectionOption(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
                      color: Colors.white,
                      size: 20,
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
}
