import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../provider/collection_cubit.dart';
import '../provider/collection_state.dart';
import '../../../post/data/models/post_simple_model.dart';
import '../widgets/post/collection_list_widget.dart';
import '../widgets/post/post_summary_card.dart';

class CollectionListPage extends StatefulWidget {
  const CollectionListPage({super.key});

  @override
  State<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends State<CollectionListPage> {
  String searchQuery = '';
  bool isExpanded = false;

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
                final query = removeDiacritics(searchQuery.toLowerCase());
                final title = removeDiacritics(recipe.title.toLowerCase());
                return title.contains(query);
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
                      // 🔹 Thanh tìm kiếm
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
                          setState(() => searchQuery = value);
                        },
                      ),
                      const SizedBox(height: 12),

                      //  Header "Bộ sưu tập" + nút mở rộng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Bộ sưu tập',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => isExpanded = !isExpanded);
                            },
                            child: Text(
                              isExpanded ? 'Thu gọn' : 'Mở rộng',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Widget danh sách bộ sưu tập
                      CollectionListWidget(
                        collections: collections,
                        isExpanded: isExpanded,
                      ),

                      const SizedBox(height: 24),

                      //  Section bài viết
                      const Text(
                        'Gần đây',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 3,
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

  // Hàm loại bỏ dấu tiếng Việt
  String removeDiacritics(String input) {
    const withDiacritics =
        'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const withoutDiacritics =
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIII OOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

    for (int i = 0; i < withDiacritics.length; i++) {
      input = input.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return input;
  }
}
