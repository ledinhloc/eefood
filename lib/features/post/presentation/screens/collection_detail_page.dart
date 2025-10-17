import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../recipe/presentation/screens/recipe_detail_page.dart';
import '../provider/collection_cubit.dart';
import '../provider/collection_state.dart';
import '../../../post/presentation/widgets/post_summary_card.dart';

class CollectionDetailPage extends StatelessWidget {
  final int collectionId;
  const CollectionDetailPage({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Collection')),
      body: BlocBuilder<CollectionCubit, CollectionState>(
        builder: (context, state) {
          final collection = state.selectedCollection;
          if (collection == null) {
            context.read<CollectionCubit>().fetchCollectionDetail(collectionId);
            return const Center(child: CircularProgressIndicator());
          }

          final posts = collection.posts ?? [];

          if (posts.isEmpty) {
            return const Center(child: Text('Chưa có bài post nào'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 220,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostSummaryCard(recipe: post);
            },
          );
        },
      ),
    );
  }
}
