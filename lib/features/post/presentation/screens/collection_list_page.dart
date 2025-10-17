import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../provider/collection_cubit.dart';
import '../provider/collection_state.dart';
import '../../../post/data/models/post_simple_model.dart';
import '../widgets/post/post_summary_card.dart';
import 'collection_detail_page.dart';

class CollectionListPage extends StatefulWidget {
  const CollectionListPage({super.key});

  @override
  State<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends State<CollectionListPage> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CollectionCubit()..fetchCollectionsByUser(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: SafeArea(
          child: BlocBuilder<CollectionCubit, CollectionState>(
            builder: (context, state) {
              if (state.status == CollectionStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state.status == CollectionStatus.failure) {
                return Center(child: Text(state.error ?? "Error"));
              }

              final collections = state.collections;

              // Tổng hợp tất cả bài post
              final List<PostSimpleModel> allRecipes = collections
                  .expand((c) => c.posts ?? [])
                  .cast<PostSimpleModel>()
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              // Lọc danh sách theo từ khóa nhập
              final filteredRecipes = allRecipes.where((recipe) {
                final query = searchQuery.toLowerCase();
                return recipe.title.toLowerCase().contains(query);
              }).toList();

              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<CollectionCubit>().fetchCollectionsByUser();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thanh tìm kiếm
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Tìm kiếm món ăn...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),

                      // Section Collection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Bộ sưu tập',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('See all',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: collections.length,
                          separatorBuilder: (_, __) =>
                          const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final collection = collections[index];
                            return GestureDetector(
                              onTap: () {
                                final cubit = context.read<CollectionCubit>();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BlocProvider.value(
                                      value: cubit,
                                      child: CollectionDetailPage(
                                          collectionId: collection.id),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (collection.coverImageUrl != null &&
                                        collection.coverImageUrl!.isNotEmpty)
                                      Image.network(
                                        collection.coverImageUrl!,
                                        fit: BoxFit.cover,
                                        height: 80,
                                        width: double.infinity,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                              height: 80,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.image),
                                            ),
                                      )
                                    else
                                      Container(
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Center(
                                            child: Icon(Icons.image)),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            collection.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${collection.posts?.length ?? 0} posts",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Section Posts (tất cả hoặc lọc)
                      const Text('Gần đây',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          return PostSummaryCard(recipe: recipe);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
