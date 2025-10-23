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
    await cubit.fetchCollectionsByUser();

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

          // Nút New Collection
          InkWell(
            onTap: () async {
              final controller = TextEditingController();
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Thêm bộ sưu tập'),
                  content: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập tên',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (controller.text.isNotEmpty) {
                          await cubit.createCollection(controller.text);
                          Navigator.pop(context);
                          await _loadCollections(); // refresh list
                        }
                      },
                      child: const Text('Tạo'),
                    ),
                  ],
                ),
              );
            },
            child: Row(
              children: const [
                Icon(Icons.add, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Thêm',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
                  leading: col.coverImageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      col.coverImageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
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