import 'package:eefood/features/post/data/models/post_collection_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../provider/collection_cubit.dart';
import '../provider/collection_state.dart';
import '../widgets/collection/collection_list_widget.dart';
import '../widgets/collection/post_summary_card.dart';

class CollectionListPage extends StatefulWidget {
  const CollectionListPage({super.key});

  @override
  State<CollectionListPage> createState() => _CollectionListPageState();
}

class _CollectionListPageState extends State<CollectionListPage> {
  String searchQuery = '';
  bool isExpanded = false;
  final cubit = getIt<CollectionCubit>()..fetchCollectionsByUser();
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateCollectionDialog(context, cubit);
        },
        backgroundColor: Colors.orange.shade400,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 30, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocBuilder<CollectionCubit, CollectionState>(
          bloc: cubit,
          builder: (context, state) {
            // if (state.status == CollectionStatus.loading) {
            //   return const Center(child: CircularProgressIndicator());
            // }
            // 🔹 Gọi hàm xử lý danh sách bài viết (đã tách riêng)
            final filteredRecipes = _getFilteredPosts(state.collections, searchQuery);
            return RefreshIndicator(
              onRefresh: () async {
                await cubit.fetchCollectionsByUser();
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
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                        ),
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

                    //🔹  Header "Bộ sưu tập" + nút mở rộng
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
                    BlocBuilder<CollectionCubit, CollectionState>(
                      builder: (context, state) {
                        final collections = state.collections;
                        if (state.status == CollectionStatus.loading &&
                            collections.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return CollectionListWidget(
                          collections: collections,
                          isExpanded: isExpanded,
                        );
                      },
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
    );
  }

  List<PostCollectionModel> _getFilteredPosts(
      List collections,
      String searchQuery,
      ) {
    final allPosts = collections
        .expand((c) => c.posts ?? [])
        .cast<PostCollectionModel>()
        .toList();

    // 🔹 Loại bỏ trùng: giữ post có updatedAt mới nhất
    final Map<int, PostCollectionModel> uniqueMap = {};
    for (final post in allPosts) {
      final existing = uniqueMap[post.postId];
      if (existing == null ||
          (post.createdAt != null &&
              (existing.createdAt == null ||
                  post.createdAt.isAfter(existing.createdAt)))) {
        uniqueMap[post.postId] = post;
      }
    }

    // 🔹 Chuyển lại thành list và sắp xếp theo thời gian tạo (mới nhất trước)
    final uniquePosts = uniqueMap.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 🔹 Lọc theo từ khóa tìm kiếm (không phân biệt dấu)
    final query = removeDiacritics(searchQuery.toLowerCase());
    return uniquePosts.where((post) {
      final title = removeDiacritics(post.title.toLowerCase());
      return title.contains(query);
    }).toList();
  }
  void _showCreateCollectionDialog(
    BuildContext parentContext,
    CollectionCubit cubit,
  ) {
    final controller = TextEditingController();

    showDialog(
      context: parentContext, // dùng context của trang có BlocProvider
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tạo bộ sưu tập mới'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Nhập tên bộ sưu tập'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(dialogContext);
                cubit.createCollection(
                  name,
                );
              },
              child: const Text('Tạo'),
            ),
          ],
        );
      },
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
