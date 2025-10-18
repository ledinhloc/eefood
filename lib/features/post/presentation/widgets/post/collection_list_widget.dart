import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/collection_model.dart';
import '../../provider/collection_cubit.dart';
import '../../screens/collection_detail_page.dart';

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
      return const Center(child: Text('Chưa có bộ sưu tập nào.'));
    }

    //Nếu đang thu gọn → hiển thị scroll ngang
    if (!isExpanded) {
      return SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: collections.length,
          separatorBuilder: (_, __) => const SizedBox(width: 5),
          itemBuilder: (context, index) {
            final collection = collections[index];
            return _CollectionItem(collection: collection);
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
        childAspectRatio: 1.2,
        crossAxisSpacing: 5,
        mainAxisSpacing: 3,
      ),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return _CollectionItem(collection: collection);
      },
    );
  }
}

class _CollectionItem extends StatelessWidget {
  final CollectionModel collection;
  const _CollectionItem({required this.collection});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CollectionCubit>();

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
        width: 140, // tăng nhẹ để dễ bố trí chữ
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Cho phép co giãn chiều cao
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa
            if (collection.coverImageUrl != null &&
                collection.coverImageUrl!.isNotEmpty)
              Image.network(
                collection.coverImageUrl!,
                fit: BoxFit.cover,
                height: 80,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image),
                ),
              )
            else
              Container(
                height: 80,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.image)),
              ),

            // Nội dung
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection.name,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis, // cắt nhẹ nếu quá dài
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${collection.posts?.length ?? 0} công thức",
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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
}

