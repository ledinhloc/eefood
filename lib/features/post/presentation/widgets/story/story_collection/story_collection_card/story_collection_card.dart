import 'package:eefood/features/post/data/models/story_collection_model.dart';
import 'package:eefood/features/post/presentation/widgets/story/story_collection/story_collection_card/story_collection_info.dart';
import 'package:flutter/material.dart';

import 'story_collection_image.dart';

class CollectionCard extends StatelessWidget {
  final StoryCollectionModel collection;
  final VoidCallback onTap;
  final bool isStoryInCollection;
  final VoidCallback? onDelete;

  const CollectionCard({
    super.key,
    required this.collection,
    required this.onTap,
    this.isStoryInCollection = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isStoryInCollection ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStoryInCollection ? Colors.green : Colors.grey.shade200,
          width: isStoryInCollection ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    // Image section
                    _buildImageSection(),
                    const SizedBox(width: 12),
                    // Info section
                    Expanded(
                      child: CollectionInfo(
                        name: collection.name,
                        description: collection.description,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status indicator
                    _buildStatusIndicator(),
                  ],
                ),
                // Action bar ở dưới
                const SizedBox(height: 10),
                _buildActionBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CollectionImage(
          imageUrl: collection.imageUrl,
          id: collection.id!,
          isSaved: isStoryInCollection,
        ),

        if (isStoryInCollection)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, size: 10, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    if (!isStoryInCollection) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        'Đã lưu',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: _buildMainActionButton()),

          if (onDelete != null) ...[
            const SizedBox(width: 8),
            _buildDeleteButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildMainActionButton() {
    final isRemove = isStoryInCollection;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isRemove ? Colors.red[50] : Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isRemove ? Colors.red[200]! : Colors.blue[200]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRemove ? Icons.remove_circle_outline : Icons.add_circle_outline,
            size: 16,
            color: isRemove ? Colors.red[700] : Colors.blue[700],
          ),
          const SizedBox(width: 6),
          Text(
            isRemove ? 'Xóa khỏi danh mục' : 'Thêm vào danh mục',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isRemove ? Colors.red[700] : Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Icon(Icons.delete_outline, size: 16, color: Colors.grey[700]),
        ),
      ),
    );
  }
}
