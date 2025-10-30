import 'package:eefood/core/di/injection.dart';
import 'package:eefood/features/post/presentation/provider/collection_cubit.dart';
import 'package:flutter/material.dart';

class AddToCollectionSheet extends StatefulWidget {
  final int postId;

  const AddToCollectionSheet({super.key, required this.postId});

  @override
  State<AddToCollectionSheet> createState() => _AddToCollectionSheetState();
}

class _AddToCollectionSheetState extends State<AddToCollectionSheet> {
  final Set<int> selected = {};
  final cubit = getIt<CollectionCubit>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    // await cubit.fetchCollectionsByUser();

    final collections = cubit.state.collections;

    // Check những collection nào chứa post hiện tại
    final existing = collections
        .where((col) =>
    col.posts?.any((post) => post.postId == widget.postId) ?? false)
        .map((e) => e.id)
        .toList();
    setState(() {
      selected.addAll(existing);
    });
  }


  @override
  Widget build(BuildContext context) {
    final collections = cubit.state.collections;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn bộ sưu tập',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Nút "Tạo bộ sưu tập mới"
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final controller = TextEditingController();
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Row(
                    children: const [
                      Icon(Icons.collections_bookmark_rounded, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Tạo bộ sưu tập',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên bộ sưu tập...',
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  actions: [
                    TextButton.icon(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      label: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.check, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      label: const Text('Tạo'),
                      onPressed: () async {
                        final name = controller.text.trim();
                        if (name.isNotEmpty) {
                          await cubit.createCollection(name);
                          Navigator.pop(context);
                          // await _loadCollections(); // refresh list
                        }
                      },
                    ),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add_circle_outline, color: Colors.orange),
                  SizedBox(width: 6),
                  Text(
                    'Bộ sưu tập mới',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: collections.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final col = collections[index];
                final isSelected = selected.contains(col.id);

                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: col.coverImageUrl != null && col.coverImageUrl!.isNotEmpty
                        ? Image.network(
                      col.coverImageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      // Nếu load ảnh lỗi -> hiển thị icon fallback
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
                    )
                        : Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                  title: Text(col.name),
                  trailing: Checkbox(
                    value: isSelected,
                    shape: const CircleBorder(),
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          selected.add(col.id);
                        } else {
                          selected.remove(col.id);
                        }
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selected.remove(col.id);
                      } else {
                        selected.add(col.id);
                      }
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () async {
                await cubit.updatePostCollections(widget.postId, selected.toList());
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text(
                'Cập nhật',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}