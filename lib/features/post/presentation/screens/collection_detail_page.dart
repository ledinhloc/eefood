import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../provider/collection_cubit.dart';
import '../provider/collection_state.dart';
import '../widgets/collection/collection_more_button.dart';
import '../widgets/collection/post_summary_card.dart';

class CollectionDetailPage extends StatefulWidget {
  final int collectionId;
  const CollectionDetailPage({super.key, required this.collectionId});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {
  final cubit = getIt<CollectionCubit>();

  @override
  void initState() {
    super.initState();
    cubit.selectCollectionDetail(widget.collectionId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionCubit, CollectionState>(
      bloc: cubit,
      builder: (context, state) {
        final collection = state.selectedCollection;

        if (collection == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFFF8C42))),
          );
        }

        final name = collection.name;
        final posts = collection.posts ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF8F8F8),

          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: true,
            title: Text(
              name.isNotEmpty ? name : '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3142),
              ),
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
            ),
            actions: [
              CollectionMoreButton(
                collection: collection,
                iconColor: Colors.black87,
                onDeleted: () => Navigator.pop(context),
              ),
            ],
          ),

          body: posts.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 230,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final post = posts[i];
              return PostSummaryCard(
                recipe: post,
                currentCollectionId: collection.id,
              );
            },
          ),
        );
      },
    );
  }

  // UI khi chưa có bài post
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8C42).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_library_outlined,
              color: Color(0xFFFF8C42),
              size: 55,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Chưa có bài viết nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3142),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Hãy thêm món ăn yêu thích của bạn!",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
