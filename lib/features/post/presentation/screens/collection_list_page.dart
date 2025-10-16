import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/collection_repository.dart';
import '../provider/collection_cubit.dart';
import '../provider/collection_state.dart';
import 'package:eefood/app_routes.dart';

class CollectionListPage extends StatelessWidget {
  const CollectionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CollectionCubit()..fetchCollectionsByUser(),
      child: BlocBuilder<CollectionCubit, CollectionState>(
        builder: (context, state) {
          if (state.status == CollectionStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == CollectionStatus.failure) {
            return Center(child: Text(state.error ?? "Error"));
          }

          return ListView.builder(
            itemCount: state.collections.length,
            itemBuilder: (context, index) {
              final collection = state.collections[index];
              return ListTile(
                leading: collection.coverImageUrl != null
                    ? Image.network(collection.coverImageUrl!)
                    : const Icon(Icons.collections_bookmark),
                title: Text(collection.name),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.collectionDetail,
                    arguments: {'collectionId': collection.id},
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
