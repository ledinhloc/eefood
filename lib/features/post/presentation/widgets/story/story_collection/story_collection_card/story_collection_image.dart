import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CollectionImage extends StatelessWidget {
  final String imageUrl;
  final int id;
  final bool isSaved;

  const CollectionImage({
    super.key,
    required this.imageUrl,
    required this.id,
    this.isSaved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Hero(
          tag: 'collection_$id',
          child: Container(
            width: 70,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade100,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.grey.shade400),
                    ),
                  ),
                ),
                errorWidget: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.collections_bookmark_sharp,
                    size: 28,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
