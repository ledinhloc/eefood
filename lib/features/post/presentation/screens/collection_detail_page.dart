import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../provider/collection_cubit.dart';
import '../provider/collection_state.dart';

class CollectionDetailPage extends StatelessWidget {
  final int collectionId;
  const CollectionDetailPage({super.key, required this.collectionId});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CollectionCubit, CollectionState>(
      builder: (context, state) {
        final collection = state.selectedCollection;
        if (collection == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Scaffold(
          appBar: AppBar(title: Text(collection.name)),
          body: ListView.builder(
            itemCount: collection.posts?.length ?? 0,
            itemBuilder: (context, index) {
              final post = collection.posts![index];
              return ListTile(
                leading: post.imageUrl != null
                    ? Image.network(post.imageUrl!)
                    : const Icon(Icons.image),
                title: Text(post.title),
                // subtitle: Text(post.username),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => PostDetailPage(post: post),
                  //   ),
                  // );
                },
              );
            },
          ),
        );
      },
    );
  }
}
