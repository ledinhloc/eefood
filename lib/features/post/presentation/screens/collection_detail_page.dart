import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../provider/collection_cubit.dart';
import '../provider/collection_state.dart';
import '../widgets/post/post_summary_card.dart';

class CollectionDetailPage extends StatefulWidget {
  final int collectionId;
  const CollectionDetailPage({super.key, required this.collectionId});

  @override
  State<CollectionDetailPage> createState() => _CollectionDetailPageState();
}

class _CollectionDetailPageState extends State<CollectionDetailPage> {

  @override
  void initState() {
    super.initState();
    context.read<CollectionCubit>().selectCollectionDetail(widget.collectionId);
  }
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionCubit, CollectionState>(
      builder: (context, state) {
        final collection = state.selectedCollection;

        if (collection == null) {
          context.read<CollectionCubit>().selectCollectionDetail(widget.collectionId);
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final name = collection.name;
        final posts = collection.posts ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(name.isNotEmpty ? name : ''),
          ),
          body: posts.isEmpty
              ? const Center(child: Text('Chưa có bài post nào'))
              : GridView.builder(
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
          ),
        );
      },
    );
  }
}
