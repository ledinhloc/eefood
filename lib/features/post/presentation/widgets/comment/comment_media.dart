import 'package:eefood/core/widgets/media_view_page.dart';
import 'package:flutter/material.dart';

class CommentMedia extends StatelessWidget {
  final List<String> images;
  final List<String> videos;

  const CommentMedia({
    super.key,
    required this.images,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    final allMedia = [
      ...images.map((url) => _MediaItem(url: url, isImage: true)),
      ...videos.map((url) => _MediaItem(url: url, isImage: false)),
    ];

    if (allMedia.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final itemSize = _calculateItemSize(allMedia.length, maxWidth);

          if (allMedia.length == 1) {
            return _buildSingleMedia(context, allMedia.first, itemSize);
          } else {
            return _buildMultipleMedia(context, allMedia, itemSize);
          }
        },
      ),
    );
  }

  double _calculateItemSize(int count, double maxWidth) {
    if (count == 1) return maxWidth * 0.8;
    if (count == 2) return (maxWidth - 4) / 2;
    return (maxWidth - 8) / 3;
  }

  Widget _buildSingleMedia(BuildContext context, _MediaItem media, double size) {
    return GestureDetector(
      onTap: () => _openMediaViewer(context, media.url, media.isImage),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: media.isImage
              ? DecorationImage(
                  image: NetworkImage(media.url),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: !media.isImage
            ? Stack(
                children: [
                  Container(color: Colors.black12),
                  const Center(
                    child: Icon(Icons.play_arrow, size: 40, color: Colors.white),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildMultipleMedia(BuildContext context, List<_MediaItem> media, double itemSize) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: media.take(4).toList().asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isMore = media.length > 4 && index == 3;

        return GestureDetector(
          onTap: () => _openMediaViewer(context, item.url, item.isImage),
          child: Container(
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: item.isImage && !isMore
                  ? DecorationImage(
                      image: NetworkImage(item.url),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: Colors.black12,
            ),
            child: isMore
                ? Container(
                    color: Colors.black54,
                    child: Center(
                      child: Text(
                        '+${media.length - 3}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                : !item.isImage
                    ? const Center(
                        child: Icon(Icons.videocam, color: Colors.white),
                      )
                    : null,
          ),
        );
      }).toList(),
    );
  }

  void _openMediaViewer(BuildContext context, String url, bool isImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MediaViewPage(
          url: url,
          isVideo: !isImage,
          isLocal: false, // Vì chúng ta dùng URL từ mạng
        ),
      ),
    );
  }
}

class _MediaItem {
  final String url;
  final bool isImage;

  _MediaItem({required this.url, required this.isImage});
}