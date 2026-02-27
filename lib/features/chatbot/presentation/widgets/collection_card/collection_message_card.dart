import 'package:cached_network_image/cached_network_image.dart';
import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/data/models/collection_model.dart';
import 'package:eefood/features/post/presentation/provider/collection_cubit.dart';
import 'package:eefood/features/post/presentation/screens/collection_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollectionMessageCard extends StatelessWidget {
  final CollectionModel collectionModel;
  const CollectionMessageCard({super.key, required this.collectionModel});

  @override
  Widget build(BuildContext context) {
    final postCount = collectionModel.posts?.length ?? 0;

    return InkWell(
      onTap: () {
        final collectionCubit = getIt<CollectionCubit>();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider(
              create: (_) => collectionCubit..fetchCollectionsByUser(),
              child: CollectionDetailPage(collectionId: collectionModel.id),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRect(
              child: collectionModel.coverImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: collectionModel.coverImageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collectionModel.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$postCount món ăn',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.collections, color: Colors.grey.shade400),
    );
  }
}
