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
      backgroundColor: const Color(0xFFFAFAFA),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF6B35),
              Color(0xFFFF8C42),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showCreateCollectionDialog(context, cubit);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.add_rounded,
            size: 32,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<CollectionCubit, CollectionState>(
          bloc: cubit,
          builder: (context, state) {
            final filteredRecipes = _getFilteredPosts(
              state.collections,
              searchQuery,
            );
            return RefreshIndicator(
              color: const Color(0xFFFF6B35),
              backgroundColor: Colors.white,
              onRefresh: () async {
                await cubit.fetchCollectionsByUser();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    //  Thanh tìm kiếm
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF636E72),
                            size: 24,
                          ),
                          hintText: 'Tìm kiếm món ăn yêu thích...',
                          hintStyle: const TextStyle(
                            color: Color(0xFFB2BEC3),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF8C42),
                              width: 2,
                            ),
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF2D3436),
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: (value) {
                          setState(() => searchQuery = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    //  Header "Bộ sưu tập"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.collections_bookmark_rounded,
                              color: Color(0xFFFF6B35),
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Bộ sưu tập',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2D3436),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            setState(() => isExpanded = !isExpanded);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF5EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  isExpanded ? 'Thu gọn' : 'Mở rộng',
                                  style: const TextStyle(
                                    color: Color(0xFFFF6B35),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less_rounded
                                      : Icons.expand_more_rounded,
                                  color: const Color(0xFFFF6B35),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Widget danh sách bộ sưu tập
                    CollectionListWidget(
                      collections: state.collections,
                      isExpanded: isExpanded,
                    ),

                    const SizedBox(height: 32),

                    //  Section Gần đây
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF6B35),
                                Color(0xFFFF8C42),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Gần đây',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2D3436),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF5EB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${filteredRecipes.length}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    //  Grid món ăn
                    filteredRecipes.isEmpty
                        ? _buildEmptyState()
                        : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        return PostSummaryCard(recipe: recipe);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget empty state đẹp
  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
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
                Icons.restaurant_menu_rounded,
                size: 64,
                color: const Color(0xFFFF6B35).withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có món ăn nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF636E72),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thêm món ăn yêu thích vào bộ sưu tập',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFB2BEC3),
              ),
            ),
          ],
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

    //  Loại bỏ trùng: giữ post có updatedAt mới nhất
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

    //  Chuyển lại thành list và sắp xếp theo thời gian tạo (mới nhất trước)
    final uniquePosts = uniqueMap.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    //  Lọc theo từ khóa tìm kiếm (không phân biệt dấu)
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
      context: parentContext,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon và title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6B35),
                            Color(0xFFFF8C42),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.collections_bookmark_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Tạo bộ sưu tập mới',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // TextField
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF2D3436),
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'VD: Món ăn Việt Nam, Bánh ngọt...',
                      hintStyle: TextStyle(
                        color: Color(0xFFB2BEC3),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF636E72),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFF6B35),
                              Color(0xFFFF8C42),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF6B35).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = controller.text.trim();
                            if (name.isEmpty) return;
                            Navigator.pop(dialogContext);
                            cubit.createCollection(name);
                            // cubit.fetchCollectionsByUser();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Tạo',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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