import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection.dart';
import '../../../../../core/widgets/custom_bottom_sheet.dart';
import '../../../data/models/collection_model.dart';
import '../../provider/collection_cubit.dart';
import '../../screens/collection_detail_page.dart';
import 'collection_more_button.dart';

class CollectionListWidget extends StatelessWidget {
  final List<CollectionModel> collections;
  final bool isExpanded;

  const CollectionListWidget({
    super.key,
    required this.collections,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (collections.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFF6B35).withOpacity(0.1),
                      const Color(0xFFFF8C42).withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.collections_bookmark_rounded,
                  size: 48,
                  color: const Color(0xFFFF6B35).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chưa có bộ sưu tập nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF636E72),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tạo bộ sưu tập đầu tiên của bạn',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFFB2BEC3),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Nếu đang thu gọn → hiển thị scroll ngang
    if (!isExpanded) {
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          itemCount: collections.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final collection = collections[index];
            return _CollectionItem(
              key: ValueKey(collection.id),
              collection: collection,
            );
          },
        ),
      );
    }

    // Nếu đang mở rộng → hiển thị grid dọc
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return _CollectionItem(
          collection: collection,
          key: ValueKey(collection.id),
        );
      },
    );
  }
}

class _CollectionItem extends StatelessWidget {
  final CollectionModel collection;
  final cubit = getIt<CollectionCubit>();

  _CollectionItem({
    required this.collection,
    required ValueKey<int> key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: CollectionDetailPage(collectionId: collection.id),
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần ảnh bìa với gradient overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh bìa
                  if (collection.coverImageUrl != null &&
                      collection.coverImageUrl!.isNotEmpty)
                    Image.network(
                      collection.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),

                  // Gradient overlay nhẹ
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Nút menu ở góc trên phải
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CollectionMoreButton(collection: collection),
                    ),
                  ),

                  // Badge số lượng công thức
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6B35),
                            Color(0xFFFF8C42),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B35).withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.restaurant_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${collection.posts?.length ?? 0}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Phần thông tin
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    collection.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF2D3436),
                      height: 1.3,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Row(
                  //   children: [
                  //     Container(
                  //       width: 3,
                  //       height: 12,
                  //       decoration: BoxDecoration(
                  //         gradient: const LinearGradient(
                  //           colors: [
                  //             Color(0xFFFF6B35),
                  //             Color(0xFFFF8C42),
                  //           ],
                  //         ),
                  //         borderRadius: BorderRadius.circular(2),
                  //       ),
                  //     ),
                  //     // const SizedBox(width: 6),
                  //     // Expanded(
                  //     //   child: Text(
                  //     //     "${collection.posts?.length ?? 0} công thức",
                  //     //     style: const TextStyle(
                  //     //       color: Color(0xFF636E72),
                  //     //       fontSize: 12,
                  //     //       fontWeight: FontWeight.w500,
                  //     //     ),
                  //     //   ),
                  //     // ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget placeholder khi không có ảnh
  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFF5EB),
            const Color(0xFFFFE5D0),
            const Color(0xFFFFD4B8),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.collections_bookmark_rounded,
          size: 48,
          color: const Color(0xFFFF8C42).withOpacity(0.4),
        ),
      ),
    );
  }
}