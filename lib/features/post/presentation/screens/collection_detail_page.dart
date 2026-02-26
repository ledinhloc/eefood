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
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final name = collection.name;
        final posts = collection.posts ?? [];

        return Scaffold(
          appBar: AppBar(
            title: Text(name.isNotEmpty ? name : ''),
            actions: [
              CollectionMoreButton(
                collection: collection,
                iconColor: Colors.black,
                onDeleted: () => Navigator.pop(context),
              ),
            ],
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

  // 🔹 Đổi tên bộ sưu tập
  void _showRenameDialog(
    BuildContext context,
    CollectionCubit cubit,
    String currentName,
  ) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Đổi tên bộ sưu tập'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nhập tên mới'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty) return;
              Navigator.pop(context);
              await cubit.updateCollection(widget.collectionId, name: newName);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  // 🔹 Xóa bộ sưu tập (xác nhận trước)
  void _showDeleteConfirmation(BuildContext context, CollectionCubit cubit) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa bộ sưu tập'),
        content: const Text('Bạn có chắc muốn xóa bộ sưu tập này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // đóng dialog
              await cubit.deleteCollection(widget.collectionId);
              if (context.mounted)
                Navigator.pop(context); // quay về trang trước
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
